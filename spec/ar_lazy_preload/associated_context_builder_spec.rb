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

    parent_context = ArLazyPreload::Context.register(
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
    parent_context = ArLazyPreload::Context.register(
      records: [user_with_post, user_without_posts],
      association_tree: [{ posts: :comments }]
    )

    described_class.new(
      parent_context: parent_context,
      association_name: :posts
    ).perform

    user_with_post.posts.each { |post| expect(post.lazy_preload_context).not_to be_nil }
  end

  it "supports polymorphic associations" do
    post = user_with_post.posts.first
    vote_for_post = build(:vote, user: user_without_posts, voteable: post)
    comment = build(:comment, user: user_without_posts, post: post)
    vote_for_comment = build(:vote, user: user_with_post, voteable: comment)

    records = [vote_for_post, vote_for_comment]
    records.each { |vote| expect(vote.voteable).not_to be_nil }

    parent_context = ArLazyPreload::Context.register(
      records: records,
      association_tree: [voteable: :user]
    )

    described_class.new(
      parent_context: parent_context,
      association_name: :voteable
    ).perform

    [post, comment].each { |voteable| expect(voteable.lazy_preload_context).not_to be_nil }
  end

  it "supports STI associations" do
    user = create(:user)
    post1 = create(:post, user: user)
    post2 = create(:private_post, user: user)

    expect(post2.level).not_to be_nil
    records = [post1, post2]

    parent_context = ArLazyPreload::Context.register(
      records: records,
      association_tree: [posts: :level]
    )

    described_class.new(
      parent_context: parent_context,
      association_name: :level
    ).perform

    [post2, post1].each { |post| expect(post.lazy_preload_context).not_to be_nil }
  end

  it "skips creating context when child association tree is blank" do
    parent_context = ArLazyPreload::Context.register(
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
    parent_context = ArLazyPreload::Context.register(
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
