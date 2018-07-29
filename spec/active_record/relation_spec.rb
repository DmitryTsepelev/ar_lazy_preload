# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Relation do
  before(:all) do
    user1 = User.create(account: Account.create(account_history: AccountHistory.create))
    user2 = User.create(account: Account.create(account_history: AccountHistory.create))

    post1 = user1.posts.create
    user1.posts.create

    user1.comments.create(post: post1)
    user2.comments.create(post: post1)
    post1.comments.create
  end

  describe "lazy_preload" do
    it "responds to lazy_preload" do
      expect(User.lazy_preload(:posts)).to respond_to(:lazy_preload)
    end

    it "stores lazy_preload_values" do
      expect(User.lazy_preload(posts: :user).lazy_preload_values).to eq([posts: :user])
    end

    it "supports chain calls" do
      relation = Comment.lazy_preload(:post).lazy_preload(:user)
      expect(relation.lazy_preload_values).to eq(%i[post user])
    end

    it "raises exception on empty arguments" do
      expect { User.lazy_preload }.to raise_exception(ArgumentError)
    end
  end

  describe "context building" do
    it "not recreates context on second load call" do
      relation = Comment.lazy_preload(:post).lazy_preload(:user)
      context = relation.load.first.lazy_preload_context
      expect(relation.load.first.lazy_preload_context).to eq(context)
    end

    it "recreates context on second reload" do
      relation = Comment.lazy_preload(:post).lazy_preload(:user)
      context = relation.load.first.lazy_preload_context
      relation.reload
      expect(relation.first.lazy_preload_context).not_to eq(context)
    end

    it "not creates context when relation is empty" do
      expect(ArLazyPreload::Context).not_to receive(:new)
      Comment.none.lazy_preload(:post).load
    end
  end

  def expect_requests_made(count)
    expect { yield if block_given? }.to make_database_queries(count: count)
  end

  RSpec.shared_examples "check initial loading" do
    it "does not load association before it's called" do
      expect_requests_made(1) { subject.inspect }
    end
  end

  describe "belongs_to" do
    include_examples "check initial loading"

    subject { Comment.lazy_preload(:user) }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(2) { subject.map { |comment| comment.user&.id } }
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
    it "does not load association which was not lazily preloaded" do
      expect_requests_made(4) do
        subject.map do |comment|
          comment.user.posts.map(&:id) if comment.user.present?
        end
      end
    end
  end

  describe "has_many" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:posts) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(2) { subject.map { |u| u.posts.map(&:id) } }
    end
  end

  describe "has_many through" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:comments_on_posts) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(3) { subject.map { |u| u.comments_on_posts.map(&:id) } }
    end
  end

  describe "has_one" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:account) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(2) { subject.map { |u| u.account.id } }
    end
  end

  describe "has_one through" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:account_history) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (?, ?)
    # SELECT "account_histories".*
    #   FROM "account_histories"
    #   WHERE "account_histories"."account_id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(3) do
        subject.map { |user| user.account_history.id }
      end
    end
  end

  describe "has_and_belongs_to_many" do
    # TODO
  end

  describe "belongs_to + has_many" do
    include_examples "check initial loading"

    subject { Comment.lazy_preload(user: { posts: :comments }) }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    it "loads lazy_preloaded association" do
      expect_requests_made(3) do
        subject.map { |comment| comment.user.posts.map(&:id) if comment.user.present? }
      end
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
    it "loads associtions lazily" do
      expect_requests_made(4) do
        subject.map do |comment|
          comment.user.posts.map { |p| p.comments.map(&:id) } if comment.user.present?
        end
      end
    end
  end

  describe "polymorphic" do
    # TODO
  end
end
