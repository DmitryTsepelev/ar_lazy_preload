# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Relation do
  before(:all) do
    user1 = User.create(account: Account.create)
    user2 = User.create(account: Account.create)

    post1 = user1.posts.create
    user1.posts.create

    user1.comments.create(post: post1)
    user2.comments.create(post: post1)
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

  describe "has_many" do
    subject { User.lazy_preload(:posts) }

    # SELECT  "users".* FROM "users" LIMIT ?
    it "does not load posts initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    it "loads posts for all users lazily" do
      expect { subject.map { |u| u.posts.map(&:id) } }.to make_database_queries(count: 2)
    end
  end

  describe "belongs_to" do
    subject { Comment.lazy_preload(:user) }

    # SELECT  "comments".* FROM "comments" LIMIT ?
    it "does not load users initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    it "loads users for all comments lazily" do
      expect { subject.map { |c| c.user.id } }.to make_database_queries(count: 2)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
    it "does not load posts lazily" do
      expect { subject.map { |c| c.user.posts.map(&:id) } }.to make_database_queries(count: 4)
    end
  end

  describe "belongs_to + has_many" do
    subject { Comment.lazy_preload(user: { posts: :comments }) }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    it "loads posts lazily" do
      expect { subject.map { |c| c.user.posts.map(&:id) } }.to make_database_queries(count: 3)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
    it "loads posts with comments lazily" do
      expect do
        subject.map { |c| c.user.posts.map { |p| p.comments.map(&:id) } }
      end.to make_database_queries(count: 4)
    end
  end

  describe "has_one" do
    subject { User.lazy_preload(:account) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (?, ?)
    it "loads accounts lazily" do
      expect { subject.map { |u| u.account.id } }.to make_database_queries(count: 2)
    end
  end

  describe "has_many through" do
    subject { User.lazy_preload(:comments_on_posts) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (?, ?)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
    it "loads accounts lazily" do
      expect do
        subject.map { |u| u.comments_on_posts.map(&:id) }
      end.to make_database_queries(count: 3)
    end
  end
end
