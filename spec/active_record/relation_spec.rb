# frozen_string_literal: true

require "spec_helper"

describe ActiveRecord::Relation do
  describe "#lazy_preload" do
    subject { User.lazy_preload(:posts) }

    it "stores lazy_preload_values" do
      expect(subject.lazy_preload_values).to eq([:posts])
    end
  end

  describe "has_many" do
    subject { User.lazy_preload(:posts) }

    before(:all) do
      user = User.create
      user.posts.create
      user.posts.create
    end

    it "does not load posts initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    it "loads posts for all users lazily" do
      expect do
        subject.each { |u| u.posts.map(&:id) }
      end.to make_database_queries(count: 2)
    end
  end

  describe "belongs_to" do
    subject { Comment.lazy_preload(:user) }

    before(:all) do
      user1 = User.create
      user2 = User.create

      post1 = user1.posts.create
      user1.posts.create

      user1.comments.create(post: post1)
      user2.comments.create(post: post1)
    end

    it "does not load users initially" do
      expect { subject.inspect }.to make_database_queries(count: 1)
    end

    it "loads users for all comments lazily" do
      expect do
        subject.each { |c| c.user.id }
      end.to make_database_queries(count: 2)
    end
  end
end
