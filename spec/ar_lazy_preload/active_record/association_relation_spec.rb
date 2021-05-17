# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::AssociationRelation do
  let(:club) { create(:club) }
  let(:user) { create(:user) }

  before do
    create :club_member, club: club, user: user, role: :owner
  end

  it "not raise any error when `owner` method already defined in model" do
    expect { p user.club_memberships.load }.not_to raise_error
  end
end
