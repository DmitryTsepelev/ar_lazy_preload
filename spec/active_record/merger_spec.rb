# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Merger do
  let(:users) { User.all }
  let(:users_with_posts) { User.lazy_preload(:posts) }
  let(:users_with_posts_and_comments) { User.lazy_preload(posts: :comments) }
  let(:posts_with_authors) { Post.lazy_preload(:user) }

  it "supports empty lazy_preload" do
    relation = users.merge(users_with_posts)
    expect(relation.lazy_preload_values).to eq([:posts])
  end

  it "supports deeper lazy_preload" do
    relation = users_with_posts.merge(users_with_posts_and_comments)
    expect(relation.lazy_preload_values).to eq([:posts, posts: :comments])
  end

  it "supports reflection" do
    relation = users_with_posts.merge(posts_with_authors)
    expect(relation.lazy_preload_values).to eq([:posts, posts: [:user]])
  end
end
