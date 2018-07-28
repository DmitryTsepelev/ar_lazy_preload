# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Relation do
  before(:all) do
    user1 = User.create
    user2 = User.create

    post1 = user1.posts.create
    user1.posts.create

    user1.comments.create(post: post1)
    user2.comments.create(post: post1)
  end

  describe "#lazy_preload" do
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
  end

  describe "has_many" do
    subject { User.lazy_preload(:posts) }

    # 1 request for users
    it "does not load posts initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    # 1 request for users and one for posts
    it "loads posts for all users lazily" do
      expect { subject.each { |u| u.posts.map(&:id) } }.to make_database_queries(count: 2)
    end
  end

  describe "belongs_to" do
    subject { Comment.lazy_preload(:user) }

    # 1 request for comments
    it "does not load users initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    # 1 request for comments and one request for users
    it "loads users for all comments lazily" do
      expect { subject.each { |c| c.user.id } }.to make_database_queries(count: 2)
    end

    # 1 request for comments, one request for users, 2 requests for posts
    it "does not load posts lazily" do
      expect { subject.each { |c| c.user.posts.map(&:id) } }.to make_database_queries(count: 4)
    end
  end

  describe "belongs_to + has_many" do
    subject { Comment.lazy_preload(user: :posts) }

    # 1 request for comments, 1 request for users, 1 request for posts
    it "loads posts lazily" do
      expect { subject.each { |c| c.user.posts.map(&:id) } }.to make_database_queries(count: 3)
    end
  end
end
