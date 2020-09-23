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

    it "does not load association with scope" do
      expect do
        subject.flat_map do |u|
          u.posts.where(
            created_at: ::Time.zone.at(0)..(::Time.zone.at(0) + 1)
          ).size
        end
      end.to_not raise_error
    end

    # SELECT "users".* FROM "users"
    # SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN (...) AND "comments"."parent_comment_id" IS NULL
    it "does not load association defined with scope" do
      expect do
        subject.flat_map do |u|
          u.thread_comments.size
        end
      end.to make_database_queries(count: 2)
    end
  end
end
