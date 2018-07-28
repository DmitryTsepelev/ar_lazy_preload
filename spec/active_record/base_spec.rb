# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Base do
  describe "#lazy_preload" do
    subject { ActiveRecord::Base }

    it { is_expected.to respond_to(:lazy_preload) }
  end
end
