# frozen_string_literal: true

require "spec_helper"

describe "ActiveRecord::Relation.preload_associations_lazily" do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  let!(:post) { create(:post, user: user1) }
  let!(:comment1) { create(:comment, user: user1, post: post) }
  let!(:comment1) { create(:comment, user: user2, post: post) }

  describe "auto preloading" do
    subject { Comment.preload_associations_lazily }

    # SELECT "comments".* FROM "comments"
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (...)
    it "loads association automatically" do
      expect { subject.each { |comment| comment.user&.id } }.to make_database_queries(count: 2)
    end
  end
end
