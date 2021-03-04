# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Contexts::TemporaryPreloadConfig do
  it "enables only inside within_context method scope" do
    expect(described_class.enabled?).to be_falsey
    expect do
      described_class.within_context do
        expect(described_class.enabled?).to be_truthy
        # We need to be sure that `enabled?` is false even in exception scenario
        raise("Some error")
      end
    end.to raise_error("Some error")

    expect(described_class.enabled?).to be_falsey
  end
end
