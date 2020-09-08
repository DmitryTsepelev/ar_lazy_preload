# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    trait :with_account do
      account
    end

    trait :with_one_post do
      posts { build_list(:post, 1) }
    end

    trait :with_one_post_and_comments do
      posts { build_list(:post, 1, :with_comments) }
    end
  end

  factory :account do
    account_history
  end

  factory :account_history

  factory :post do
    trait :with_comments do
      comments { build_list(:comment, 3) }
    end
  end

  factory :private_post do
    level

    trait :level_two do
      association :level, :level_two
    end
  end

  factory :level do
    name { "Level one" }

    trait :level_two do
      name { "Level two" }
    end
  end

  factory :comment do
    user
  end

  factory :vote
end
