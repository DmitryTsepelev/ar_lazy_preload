# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::AssociatedContextBuilder do
  let(:user_without_posts) { build(:user) }
  let(:user_with_post) { build(:user, :with_account, :with_one_post) }

  it "supports singular associations" do
    # make sure associations are loaded
    expect(user_without_posts.account).to be_nil
    expect(user_with_post.posts).not_to be_blank
    expect(user_with_post.account).not_to be_nil

    parent_context = ArLazyPreload::Context.new(
      model: User,
      records: [user_with_post, user_without_posts],
      association_tree: [{ account: :account_history }]
    )

    described_class.new(
      parent_context: parent_context,
      association_name: :account
    ).perform

    expect(user_with_post.account.lazy_preload_context).not_to be_nil
  end

  it "supports collection associations" do
    parent_context = ArLazyPreload::Context.new(
      model: User,
      records: [user_with_post, user_without_posts],
      association_tree: [{ posts: :comments }]
    )

    described_class.new(
      parent_context: parent_context,
      association_name: :posts
    ).perform

    user_with_post.posts.each { |post| expect(post.lazy_preload_context).not_to be_nil }
  end

  it "skips creating context when child association tree is blank" do
    parent_context = ArLazyPreload::Context.new(
      model: User,
      records: [user_with_post, user_without_posts],
      association_tree: [:posts]
    )

    expect(ArLazyPreload::Context).not_to receive(:new)

    described_class.new(
      parent_context: parent_context,
      association_name: :posts
    ).perform

    user_with_post.posts.each { |post| expect(post.lazy_preload_context).to be_nil }
  end

  it "skips creating context when list of associated records is blank" do
    parent_context = ArLazyPreload::Context.new(
      model: User,
      records: [user_without_posts],
      association_tree: [{ posts: :comments }]
    )

    expect(ArLazyPreload::Context).not_to receive(:new)

    described_class.new(
      parent_context: parent_context,
      association_name: :posts
    ).perform
  end
end
