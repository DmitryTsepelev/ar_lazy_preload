# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Relation do
  before(:all) do
    user1 = create(:user, :with_account)
    user2 = create(:user, :with_account)

    post1 = create(:post, user: user1)
    user2.vote_for(post1)
    comment1 = create(:comment, user: user1, post: post1, mentioned_users: [user2])
    user2.vote_for(comment1)
    create(:comment, user: user2, parent_comment: comment1)

    post2 = create(:post, user: user1)
    user1.vote_for(post2)
    comment2 = create(:comment, user: user2, post: post1, mentioned_users: [user1])
    user1.vote_for(comment2)
    create(:comment, user: user1, parent_comment: comment2)
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

  describe "belongs_to" do
    include_examples "check initial loading"

    subject { Comment.lazy_preload(:user) }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.each { |comment| comment.user&.id } }.to make_database_queries(count: 2)
    end
  end

  describe "has_many" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:posts) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.each { |u| u.posts.map(&:id) } }.to make_database_queries(count: 2)
    end
  end

  describe "has_many through" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:comments_on_posts) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (...)
    it "loads lazy_preloaded association" do
      expect do
        subject.each { |u| u.comments_on_posts.map(&:id) }
      end.to make_database_queries(count: 3)
    end
  end

  describe "has_one" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:account) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.each { |u| u.account.id } }.to make_database_queries(count: 2)
    end
  end

  describe "has_one through" do
    include_examples "check initial loading"

    subject { User.lazy_preload(:account_history) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (...)
    # SELECT "account_histories".*
    #   FROM "account_histories"
    #   WHERE "account_histories"."account_id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.each { |user| user.account_history.id } }.to make_database_queries(count: 3)
    end
  end

  describe "has_and_belongs_to_many" do
    include_examples "check initial loading"

    subject { Comment.lazy_preload(mentioned_users: :posts) }

    # SELECT "comments".* FROM "comments"
    # SELECT "user_mentions".* FROM "user_mentions" WHERE "user_mentions"."comment_id" IN (...)
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    it "loads lazy_preloaded association" do
      expect do
        subject.each { |comment| comment.mentioned_users.map(&:id) }
      end.to make_database_queries(count: 3)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "user_mentions".* FROM "user_mentions" WHERE "user_mentions"."comment_id" IN (...)
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    it "loads embedded lazy_preloaded association" do
      expect do
        subject.each { |comment| comment.mentioned_users.map { |u| u.posts.map(&:id) } }
      end.to make_database_queries(count: 4)
    end
  end

  describe "belongs_to + has_many" do
    include_examples "check initial loading"

    subject { Comment.lazy_preload(user: { posts: :comments }) }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    it "loads lazy_preloaded association" do
      expect do
        subject.each { |comment| comment.user.posts.map(&:id) if comment.user.present? }
      end.to make_database_queries(count: 3)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (...)
    it "loads embedded lazy_preloaded association" do
      expect do
        subject.map do |comment|
          comment.user.posts.map { |p| p.comments.map(&:id) } if comment.user.present?
        end
      end.to make_database_queries(count: 4)
    end
  end

  describe "polymorphic" do
    include_examples "check initial loading"

    subject { Vote.lazy_preload(:voteable) }

    # SELECT "votes".* FROM "votes"
    # SELECT "posts".* FROM "posts" WHERE "posts"."id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.map { |vote| vote.voteable.id } }.to make_database_queries(count: 3)
    end
  end

  describe "self_join" do
    include_examples "check initial loading"

    subject { Comment.threads.lazy_preload(:replies) }

    # SELECT "comments".* FROM "comments"
    # SELECT "comments".* FROM "comments" WHERE "comments"."parent_comment_id" IN (...)
    it "loads lazy_preloaded association" do
      expect do
        subject.map { |comment| comment.replies.map(&:id) }
      end.to make_database_queries(count: 2)
    end
  end
end
