# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    trait :with_account do
      account
    end

    trait :with_one_post do
      posts { build_list(:post, 1) }
    end
  end

  factory :account do
    account_history
  end

  factory :account_history

  factory :post

  factory :comment
end
