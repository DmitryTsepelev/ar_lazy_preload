# frozen_string_literal: true

require "spec_helper"

describe "ActiveRecord::Relation.preload_associations_lazily" do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  let!(:post_1) { create(:post, user: user1) }
  let!(:post_2) { create(:post, user: user2) }

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

    # SELECT "posts".* FROM "posts"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN (...)
    it "loads association of association automatically when `includes` called" do
      expect do
        Post.includes(:user).preload_associations_lazily.each do |p|
          p.user.comments.load
        end
      end.to make_database_queries(count: 3)
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
