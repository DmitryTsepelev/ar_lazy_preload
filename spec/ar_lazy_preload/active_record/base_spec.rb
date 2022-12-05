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

  describe "#find_by" do
    subject { User.find_by(id: user.id) }

    let(:user) { create(:user) }

    it "not creates_context" do
      expect(subject.lazy_preload_context).to be_nil
    end
  end

  describe "#reload" do
    let!(:user) { create(:user) }

    it "not looses context" do
      user = User.lazy_preload(posts: :user).first

      user.reload.lazy_preload_context.tap do |context|
        expect(context).not_to be_nil
      end
    end
  end
end
