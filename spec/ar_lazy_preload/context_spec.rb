# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Context do
  let(:user_without_posts) { create(:user) }
  let(:user_with_post) do
    user = create(:user)
    post = create(:post, user: user)
    create(:comment, post: post, user: user)
    user
  end

  subject! do
    described_class.new(
      records: [user_with_post, user_without_posts, nil],
      association_tree: [comments: :post]
    )
  end

  describe "#initialize" do
    it "assigns context for each record" do
      subject.records.each do |user|
        next if user.nil?

        expect(user.lazy_preload_context).to eq(subject)
      end
    end

    it "does not compact records" do
      expect(subject.records.size).to eq(3)
    end
  end

  describe "#try_preload_lazily" do
    it "does not preload association when it's not in the association_tree" do
      subject.try_preload_lazily(:posts)
      subject.records.each do |user|
        next if user.nil?

        expect(user.posts.loaded?).to be_falsey
      end
    end

    it "preloads association when it's in the association_tree" do
      subject.try_preload_lazily(:comments)
      subject.records.each do |user|
        next if user.nil?

        expect(user.comments.loaded?).to be_truthy
      end
    end

    it "creates child preloading context" do
      subject.try_preload_lazily(:comments)
      subject.records.each do |user|
        next if user.nil?

        user.comments.each do |comment|
          expect(comment.lazy_preload_context).not_to be_nil
        end
      end
    end
  end
end
