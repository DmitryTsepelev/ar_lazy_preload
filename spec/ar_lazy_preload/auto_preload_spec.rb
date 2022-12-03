# frozen_string_literal: true

require "spec_helper"

describe "ArLazyPreload.config.auto_preload" do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  let!(:post) { create(:post, user: user1) }
  let!(:comment1) { create(:comment, user: user1, post: post) }
  let!(:comment2) { create(:comment, user: user2, post: post) }

  before(:each) { ArLazyPreload.config.auto_preload = true }

  describe "auto preloading" do
    subject { Comment.all }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    it "loads association automatically" do
      expect { subject.map { |comment| comment.user&.id } }.to make_database_queries(count: 2)
    end
  end

  describe "#find_by" do
    subject { User.find_by(id: user.id) }

    let(:user) { create(:user) }

    it "creates_context" do
      expect(subject.lazy_preload_context).not_to be_nil
    end
  end

  describe "when new record is saved" do
    subject { comment }

    let!(:comment) { create(:comment, user_id: user.id, post: post) }
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    before do
      create_list(:post, 3, :with_comments, user: user)
    end

    # SELECT "users".* FROM "users" WHERE "users"."id" = ?
    # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
    # SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN (?, ?)
    it "adds context to saved record" do
      expect { subject.user.posts.map { |post| post.comments.map(&:id) } }.to \
        make_database_queries(count: 3)
    end
  end
end
