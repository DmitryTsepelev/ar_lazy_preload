# frozen_string_literal: true

require 'spec_helper'

describe ArLazyPreload::AssociationRelation do
  let(:user) do
    user = create :user
    club = create :club
    create :club_member, club: club, user: user, role: :owner
    user
  end

  it 'not raise any error when `owner` method already defined in model' do
    expect { p user.club_memberships }.not_to raise_error
  end
end
