# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.timestamps null: false
  end

  create_table :posts do |t|
    t.references :user, foreign_key: true
    t.string :type
    t.references :level, foreign_key: true

    t.timestamps null: false
  end

  create_table :levels do |t|
    t.references :post, foreign_key: true
    t.string :name

    t.timestamps null: false
  end

  create_table :comments do |t|
    t.references :post, foreign_key: true
    t.references :user, foreign_key: true
    t.integer :parent_comment_id, foreign_key: true, table_name: :comments

    t.timestamps null: false
  end

  create_table :accounts do |t|
    t.references :user, foreign_key: true

    t.timestamps null: false
  end

  create_table :account_histories do |t|
    t.references :account, foreign_key: true

    t.timestamps null: false
  end

  create_table :user_mentions do |t|
    t.references :comment
    t.references :user

    t.timestamps null: false
  end

  create_table :votes do |t|
    t.references :voteable, polymorphic: true, index: true
    t.references :user, foreign_key: true

    t.timestamps null: false
  end
end
