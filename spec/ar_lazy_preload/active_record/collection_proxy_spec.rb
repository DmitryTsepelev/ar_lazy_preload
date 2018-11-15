# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::CollectionProxy do
  let(:user_with_post) do
    user = create(:user)
    post = create(:post, user: user)
    create(:comment, post: post, user: user)
    user
  end

  describe "#lazy_preload" do
    # `CollectionProxy` is a bit different from `Relation`
    it "can load a collection proxy" do
      expect(user_with_post.posts).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect { user_with_post.posts.load }.not_to raise_exception
    end
  end

  describe "#load" do
    let(:relation) { user_with_post.posts.lazy_preload(:comments) }

    it "not recreates context on second load call" do
      relation.load
      initial_context = relation.first.lazy_preload_context

      relation.load
      expect(relation.first.lazy_preload_context).to eq(initial_context)
    end

    it "recreates context on reload call" do
      relation.load
      initial_context = relation.first.lazy_preload_context

      relation.reload
      expect(relation.first.lazy_preload_context).not_to eq(initial_context)
    end

    it "not creates context when relation is empty" do
      expect(ArLazyPreload::Context).not_to receive(:new)
      relation.none.lazy_preload(:post).load
    end

    it "stores correct lazy_preload_values" do
      expect(relation.lazy_preload_values).to eq([:comments])
    end
  end
end
