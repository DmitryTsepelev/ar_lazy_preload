# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload do
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

    create(:private_post, user: user1)
    create(:private_post, :level_two, user: user1)
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

    it "loads lazy_preloaded association with collection_singular_ids" do
      expect { subject.map(&:post_ids) }.to make_database_queries(count: 2)
    end

    context "when STI association implemented not for all" do
      subject { User.lazy_preload(posts: [:level]) }

      # SELECT "users".* FROM "users"
      # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
      # SELECT "levels".* FROM "levels" WHERE "levels"."id" IN (...)
      it "loads lazy_preloaded STI association" do
        expect do
          subject.flat_map(&:posts).each do |post|
            post.is_a?(PrivatePost) ? post.level.id : post.id
          end
        end.to make_database_queries(count: 3)
      end
    end

    context "when the relation has a scope" do
      context "when the scope takes no argument" do
        subject { Post.lazy_preload(:comment_threads) }

        it "loads lazy_preloaded associations" do
          expect do
            subject.map do |post|
              post.comment_threads.map(&:id)
            end
          end.to make_database_queries(count: 2)
        end
      end

      context "when the scope takes an argument and is instance-dependant" do
        subject { User.lazy_preload(posts: :comments_mentioning_user).first }

        if ::ActiveRecord::VERSION::MAJOR >= 7
          # SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?
          # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
          # SELECT "comments".*
          #   FROM "comments"
          #   WHERE (comments.body LIKE NULL) AND "comments"."post_id" IN (...)
          it "loads lazy_preloaded associations" do
            expect do
              subject.posts.map do |post|
                post.comments_mentioning_user.map(&:id)
              end
            end.to make_database_queries(count: 3)
          end
        else
          # SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?
          # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
          # SELECT "comments".*
          #   FROM "comments"
          #   WHERE "comments"."post_id" = ? AND (comments.body LIKE NULL)
          # SELECT "comments".*
          #   FROM "comments"
          #   WHERE "comments"."post_id" = ? AND (comments.body LIKE NULL)
          # SELECT "comments".*
          #   FROM "comments"
          #   WHERE "comments"."post_id" = ? AND (comments.body LIKE NULL)
          # SELECT "comments".*
          #   FROM "comments"
          #   WHERE "comments"."post_id" = ? AND (comments.body LIKE NULL)
          it "doesn't load lazy_preloaded associations" do
            expect do
              subject.posts.map do |post|
                post.comments_mentioning_user.map(&:id)
              end
            end.to make_database_queries(count: 6)
          end
        end
      end
    end
  end

  describe "has_many through" do
    include_examples "check initial loading"

    subject { User.lazy_preload(comments_on_posts: :user) }

    # SELECT "users".* FROM "users"
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (...)
    it "loads lazy_preloaded association" do
      expect do
        subject.each { |u| u.comments_on_posts.map(&:id) }
      end.to make_database_queries(count: 3)
    end

    it "loads lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.map(&:comments_on_post_ids)
      end.to make_database_queries(count: 3)
    end

    it "passes lazy_preload_values down" do
      subject.each do |user|
        user.comments_on_posts.each do |comment|
          expect(comment.lazy_preload_context.association_tree).to eq([:user])
        end
      end
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

    subject { User.lazy_preload(account_history: :account) }

    # SELECT "users".* FROM "users"
    # SELECT "accounts".* FROM "accounts" WHERE "accounts"."user_id" IN (...)
    # SELECT "account_histories".*
    #   FROM "account_histories"
    #   WHERE "account_histories"."account_id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.each { |user| user.account_history.id } }.to make_database_queries(count: 3)
    end

    it "passes lazy_preload_values down" do
      subject.each do |user|
        child_context = user.account_history.lazy_preload_context
        expect(child_context.association_tree).to eq([:account])
      end
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

    it "loads lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.map(&:mentioned_user_ids)
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

    it "loads embedded lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.each { |comment| comment.mentioned_users.map(&:post_ids) }
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
        subject.each { |comment| comment.user.posts.map(&:id) }
      end.to make_database_queries(count: 3)
    end

    it "loads lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.each { |comment| comment.user.post_ids }
      end.to make_database_queries(count: 3)
    end

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (...)
    it "loads embedded lazy_preloaded association" do
      expect do
        subject.map do |comment|
          comment.user.posts.map { |p| p.comments.map(&:id) }
        end
      end.to make_database_queries(count: 4)
    end

    it "loads embedded lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.map do |comment|
          comment.user.posts.map(&:comment_ids)
        end
      end.to make_database_queries(count: 4)
    end
  end

  describe "polymorphic" do
    include_examples "check initial loading"

    subject { Vote.lazy_preload(voteable: :user) }

    # SELECT "votes".* FROM "votes"
    # SELECT "posts".* FROM "posts" WHERE "posts"."id" IN (...)
    # SELECT "comments".* FROM "comments" WHERE "comments"."id" IN (...)
    it "loads lazy_preloaded association" do
      expect { subject.map { |vote| vote.voteable.id } }.to make_database_queries(count: 3)
    end

    if ::ActiveRecord::VERSION::MAJOR >= 7
      # SELECT "votes".* FROM "votes"
      # SELECT "posts".* FROM "posts" WHERE "posts"."id" IN (...)
      # SELECT "comments".* FROM "comments" WHERE "comments"."id" IN (...)
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (...) - for posts
      it "loads embedded lazy_preloaded association" do
        # we have 4 queries because new preloader knows how to batch queries to the same table
        expect { subject.map { |vote| vote.voteable.user.id } }.to make_database_queries(count: 4)
      end
    else
      # SELECT "votes".* FROM "votes"
      # SELECT "posts".* FROM "posts" WHERE "posts"."id" IN (...)
      # SELECT "comments".* FROM "comments" WHERE "comments"."id" IN (...)
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (...) - for posts
      # SELECT "users".* FROM "users" WHERE "users"."id" IN (...) - for comments
      it "loads embedded lazy_preloaded association" do
        expect { subject.map { |vote| vote.voteable.user.id } }.to make_database_queries(count: 5)
      end
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

    it "loads lazy_preloaded association with collection_singular_ids" do
      expect do
        subject.map(&:reply_ids)
      end.to make_database_queries(count: 2)
    end
  end
end
