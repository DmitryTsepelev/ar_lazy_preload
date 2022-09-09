# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Base do
  describe "#lazy_preload" do
    subject { ActiveRecord::Base }

    it { is_expected.to respond_to(:lazy_preload) }
  end

  describe "#skip_preload" do
    subject { User.new }

    it { is_expected.to respond_to(:skip_preload) }
  end

  describe "#reload" do
    it "should keep the context" do
      create(:user)
      user = User.preload_associations_lazily.first
      puts user.lazy_preload_context.inspect
      user.reload
      puts user.lazy_preload_context.inspect
    end
  end
end
