# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::PreloadedRecordsConverter do
  let!(:user) do
    create(:user).tap do |u|
      create(:post, user: u)
      create(:post, user: u)
    end
  end

  it "returns array if array is passed" do
    expect(described_class.call([1, 2, 3])).to eq([1, 2, 3])
  end

  context "when relation" do
    let(:relation) { User.find_by(id: user.id).posts }

    it "returns array for preloaded relation" do
      expect(described_class.call(relation.load).map(&:id)).to match_array(user.posts.map(&:id))
    end

    it "raises error if relation is not loaded" do
      expect { described_class.call(relation) }.to raise_error(
        ArgumentError, "The relation is not preloaded"
      )
    end
  end

  it "raises error for unknown class" do
    expect { described_class.call(nil) }.to raise_error(
      ArgumentError, "Unsupported class for preloaded records"
    )
  end
end
