# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::AssociationTreeBuilder do
  context "#initialize" do
    it "removes symbols from initial tree" do
      subject = described_class.new([:user, { comments: :users }])
      expect(subject.association_tree).to eq([comments: :users])
    end
  end

  context "#subtree_for" do
    it "does not support other inputs" do
      expect { described_class.new(:boom) }.to raise_error(NotImplementedError)
    end

    it "supports symbols" do
      subject = described_class.new([:user])
      expect(subject.subtree_for(:user)).to eq([])
    end

    it "supports hashes" do
      subject = described_class.new([user: :comments])
      expect(subject.subtree_for(:user)).to eq([:comments])
    end

    it "supports arrays in single hash" do
      subject = described_class.new(user: [{ posts: :comments }])
      expect(subject.subtree_for(:user)).to eq([{ posts: :comments }])
    end

    it "supports arrays in array of hashes" do
      subject = described_class.new([{ user: [{ posts: :comments }] }])
      expect(subject.subtree_for(:user)).to eq([{ posts: :comments }])
    end
  end
end
