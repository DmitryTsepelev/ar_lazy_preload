# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::AssociationTreeBuilder do
  it "supports symbols" do
    subject = described_class.new([:user])
    expect(subject.subtree_for(:user)).to eq([])
  end

  it "supports hashes" do
    subject = described_class.new([user: :comments])
    expect(subject.subtree_for(:user)).to eq([:comments])
  end
end
