# frozen_string_literal: true

require "spec_helper"

describe "Integrity Check" do
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

  describe "has_many" do
    let(:lazy_user) { User.lazy_preload(:posts) }
    let(:include_user) { User.includes(:posts) }

    it "passes integrity check of lazy_preloaded association" do
      lazy_posts = lazy_user.map(&:posts)

      expect(lazy_posts).to be_any
      expect(lazy_posts).to eq(include_user.map(&:posts))
    end

    it "passes integrity check of lazy_preloaded association with collection_singular_ids" do
      lazy_ids = lazy_user.map(&:post_ids)

      expect(lazy_ids).to be_any
      expect(lazy_ids).to eql(include_user.map(&:post_ids))
    end
  end

  describe "has_many through" do
    let(:lazy_user) { User.lazy_preload(comments_on_posts: :user) }
    let(:include_user) { User.includes(comments_on_posts: :user) }

    it "passes integrity check of lazy_preloaded association" do
      lazy_posts = lazy_user.map(&:comments_on_posts)
      included_posts = include_user.map(&:comments_on_posts)

      expect(lazy_posts).to be_any
      expect(lazy_posts).to eq(included_posts)
    end

    it "passes integrity check of lazy_preloaded association with collection_singular_ids" do
      lazy_post_ids = lazy_user.map(&:comments_on_post_ids)
      included_post_ids = include_user.map { |u| u.comments_on_posts.map(&:id) }

      expect(lazy_post_ids).to be_any
      expect(lazy_post_ids).to eq(included_post_ids)
    end
  end

  describe "has_and_belongs_to_many" do
    let(:lazy_comment) { Comment.lazy_preload(mentioned_users: :posts) }
    let(:include_comment) { Comment.includes(mentioned_users: :posts) }

    it "passes integrity check of lazy_preloaded association" do
      lazy_mentioned_users = lazy_comment.map(&:mentioned_users)
      included_mentioned_users = include_comment.map(&:mentioned_users)

      expect(lazy_mentioned_users).to be_any
      expect(lazy_mentioned_users).to eq(included_mentioned_users)
    end

    it "passes integrity check of lazy_preloaded association with collection_singular_ids" do
      lazy_mentioned_user_ids = lazy_comment.map(&:mentioned_user_ids)
      included_mentioned_user_ids = include_comment.map { |c| c.mentioned_users.map(&:id) }

      expect(lazy_mentioned_user_ids).to be_any
      expect(lazy_mentioned_user_ids).to eq(included_mentioned_user_ids)
    end
  end

  describe "belongs_to + has_many" do
    let(:lazy_comment) { Comment.lazy_preload(user: { posts: :comments }) }
    let(:include_comment) { Comment.includes(user: { posts: :comments }) }
    it "passes integrity check of lazy_preloaded association" do
      lazy_post_ids = lazy_comment.map { |c| c.user.posts.map(&:id) }
      included_post_ids = include_comment.map { |c| c.user.posts.map(&:id) }

      expect(lazy_post_ids).to be_any
      expect(lazy_post_ids).to eq(included_post_ids)
    end

    it "passes integrity check of lazy_preloaded association with collection_singular_ids" do
      lazy_post_ids = lazy_comment.map { |c| c.user.post_ids }
      included_post_ids = include_comment.map { |c| c.user.post_ids }

      expect(lazy_post_ids).to be_any
      expect(lazy_post_ids).to eq(included_post_ids)
    end
  end
end
