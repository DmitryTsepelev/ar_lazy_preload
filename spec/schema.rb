# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true, &:timestamps

  create_table :posts do |t|
    t.references :user, foreign_key: true

    t.timestamps
  end

  create_table :comments do |t|
    t.references :post, foreign_key: true
    t.references :user, foreign_key: true

    t.timestamps
  end

  create_table :accounts do |t|
    t.references :user, foreign_key: true

    t.timestamps
  end

  create_table :account_histories do |t|
    t.references :account, foreign_key: true

    t.timestamps
  end

  create_table :user_mentions do |t|
    t.references :comment
    t.references :user

    t.timestamps
  end

  create_table :votes do |t|
    t.references :voteable, polymorphic: true, index: true
    t.references :user, foreign_key: true

    t.timestamps
  end
end
