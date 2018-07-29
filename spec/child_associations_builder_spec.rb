# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::ChildAssociationsBuilder do
  it "supports symbols" do
    subject = described_class.new([:user])
    expect(subject.build(:user)).to eq([])
  end

  it "supports hashes" do
    subject = described_class.new([user: :comments])
    expect(subject.build(:user)).to eq([:comments])
  end
end
