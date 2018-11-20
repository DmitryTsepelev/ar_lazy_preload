# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Relation do
  let!(:post) { create(:post, :with_comments) }
  let!(:user_1) { create(:user, :with_account, :with_one_post_and_comments) }
  let!(:user_2) { create(:user, :with_account, :with_one_post_and_comments) }

  describe "#lazy_preload" do
    it "responds to lazy_preload" do
      relation = User.lazy_preload(posts: :user)
      expect(relation).to respond_to(:lazy_preload)
    end

    it "supports chained calls" do
      relation = Comment.lazy_preload(:post).lazy_preload(:user)
      expect(relation.lazy_preload_values).to eq(%i[post user])
    end

    it "raises exception on empty arguments" do
      expect { User.lazy_preload }.to raise_exception(ArgumentError)
    end
  end

  describe "#lazy_preload_values" do
    it "not responds to lazy_preload_values=" do
      relation = User.lazy_preload(posts: :user)
      expect(relation).not_to respond_to(:lazy_preload_values=)
    end

    it "stores lazy_preload_values" do
      relation = User.lazy_preload(posts: :user)
      expect(relation.lazy_preload_values).to eq([posts: :user])
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "posts".* FROM "posts" WHERE "posts"."id" IN (...)
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    it "loads lazy_preloaded association" do
      comments = Comment.lazy_preload(
        post: [
          {
            user: [
              {
                posts: :comments
              }
            ]
          }
        ]
      )
      expect do
        comments.each do |comment|
          comment&.post&.user&.id
        end
      end.to make_database_queries(count: 3)
    end
  end

  describe "#scope" do
    subject do
      relation = Post.lazy_preload(comments: :user).load
      association = relation.first.association(:comments)
      association.scope
    end

    it { is_expected.to be_a(ActiveRecord::Relation) }

    it "sets up lazy_preload_values" do
      expect(subject.lazy_preload_values).to eq([:user])
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    it "loads lazy_preloaded association" do
      scope = subject
      expect { scope.each { |comment| comment.user.id } }.to make_database_queries(count: 2)
    end
  end

  describe "#load" do
    let(:relation) { Comment.lazy_preload(:post) }

    it "not recreates context on second load call" do
      relation.load
      initial_context = relation.first.lazy_preload_context

      relation.load
      expect(relation.first.lazy_preload_context).to eq(initial_context)
    end

    it "recreates context on reload call" do
      relation.load
      initial_context = relation.first.lazy_preload_context

      relation.reload
      expect(relation.first.lazy_preload_context).not_to eq(initial_context)
    end

    it "not creates context when relation is empty" do
      expect(ArLazyPreload::Context).not_to receive(:new)
      Comment.none.lazy_preload(:post).load
    end
  end
end
