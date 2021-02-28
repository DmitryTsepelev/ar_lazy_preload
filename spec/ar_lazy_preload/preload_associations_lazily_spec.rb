# frozen_string_literal: true

require "spec_helper"

describe "ActiveRecord::Relation.preload_associations_lazily" do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  let!(:post_1) { create(:post, user: user1) }
  let!(:post_2) { create(:post, user: user2) }

  let!(:comment_1) { create(:comment, user: user1, post: post_1) }
  let!(:comment_2) { create(:comment, user: user2, post: post_2) }

  let!(:vote_1) { create(:vote, voteable: comment_1, user: user1) }
  let!(:vote_2) { create(:vote, voteable: comment_1, user: user1) }

  let!(:vote_3) { create(:vote, voteable: comment_2, user: user2) }
  let!(:vote_4) { create(:vote, voteable: comment_2, user: user2) }

  describe "auto preloading" do
    subject { User.preload_associations_lazily }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    it "loads association automatically" do
      expect { subject.each { |u| u.posts.map(&:id) } }.to make_database_queries(count: 2)
    end

    # SELECT "posts".* FROM "posts"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN (...)
    it "loads association of association automatically" do
      expect do
        Post.preload_associations_lazily.each do |p|
          p.user.comments.load
        end
      end.to make_database_queries(count: 3)
    end

    if ::ActiveRecord::VERSION::MAJOR >= 6
      # SELECT "posts".* FROM "posts"
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
      # SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN (...)
      it "loads association of association automatically when `preload` called" do
        expect do
          Post.preload(:user).preload_associations_lazily.each do |p|
            p.user.comments.to_a
          end
        end.to make_database_queries(count: 3)
      end

      # SELECT "posts".* FROM "posts"
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
      # SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN (...)
      it "loads association of association automatically when `includes` called" do
        expect do
          Post.includes(:user).preload_associations_lazily.each do |p|
            p.user.comments.to_a
          end
        end.to make_database_queries(count: 3)
      end

      # SELECT "posts".* FROM "posts"
      # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
      # SELECT "votes".* FROM "votes" WHERE "votes"."user_id" IN (?, ?)
      it "loads association of association automatically when `includes` in deep nested" do
        expect do
          Post.preload_associations_lazily.each do |post|
            post.comments_with_preloaded_users.each do |comment|
              comment.user.votes.to_a
            end
          end
        end.to make_database_queries(count: 4)
      end

      context "with preloader" do
        let(:preloader) { ActiveRecord::Associations::Preloader.new }

        it "for records with different context, preloaded records should have different context" do
          user1_with_context = subject.find_by(id: user1.id)
          user2_with_context = subject.find_by(id: user2.id)

          preloader.preload([user1_with_context, user2_with_context], :posts)
          expect(user1_with_context.posts.first.lazy_preload_context).not_to eq(
            user2_with_context.posts.first.lazy_preload_context
          )
        end

        it "for records withing same context, preloaded records should inherit context" do
          user1_with_context, user2_with_context = subject.where(id: [user1.id, user2.id])

          preloader.preload([user1_with_context, user2_with_context], :posts)
          expect(user1_with_context.posts.first.lazy_preload_context).to eq(
            user2_with_context.posts.first.lazy_preload_context
          )
        end
      end
    end

    it "does not load association with scope" do
      expect do
        subject.flat_map do |u|
          u.posts.where(
            created_at: ::Time.zone.at(0)..(::Time.zone.at(0) + 1)
          ).size
        end
      end.to_not raise_error
    end
  end
end
