# frozen_string_literal: true

require "spec_helper"

describe "ArLazyPreload.skip_preload" do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }

  let!(:post1) { create(:post, user: user1) }
  let!(:post2) { create(:post, user: user1) }
  let!(:post3) { create(:post, user: user2) }

  before(:each) { ArLazyPreload.config.auto_preload = true }

  describe "#skip_preload" do
    subject { User.all }

    it "after skip preload, changed lazy preload context" do
      subject.load.last.skip_preload
      expect(subject.last.lazy_preload_context).to be(nil)
      expect(subject.first.lazy_preload_context.records).not_to include(subject.last)
    end

    it "only load own association" do
      subject.each do |user|
        # SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?
        expect do
          user.skip_preload.posts.load
        end.to make_database_queries(matching: "\"posts\".\"user_id\" = ?")
      end
    end

    it "loads excluded association" do
      subject.load.last.skip_preload.posts.to_a
      id_concat = subject[0..-2].map(&:id).join(", ")
      question_concat = (["?"] * (subject.size - 1)).join(", ")
      expect do
        subject.first.posts.to_a
      end.to make_database_queries(
        matching: /"user_id" IN ([(#{id_concat})|(#{question_concat})])/
      )
    end
  end
end
