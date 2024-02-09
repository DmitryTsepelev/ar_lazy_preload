# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name

    t.timestamps null: false
  end

  create_table :posts do |t|
    t.references :user
    t.string :type
    t.references :level

    t.timestamps null: false
  end

  create_table :levels do |t|
    t.string :name

    t.timestamps null: false
  end

  create_table :comments do |t|
    t.references :post
    t.references :user
    t.integer :parent_comment_id
    t.text :body

    t.timestamps null: false
  end

  create_table :accounts do |t|
    t.references :user, foreign_key: true

    t.timestamps null: false
  end

  create_table :account_histories do |t|
    t.references :account

    t.timestamps null: false
  end

  create_table :user_mentions do |t|
    t.references :comment
    t.references :user

    t.timestamps null: false
  end

  create_table :votes do |t|
    t.references :voteable, polymorphic: true, index: true
    t.references :user

    t.timestamps null: false
  end

  create_table :clubs do |t|
    t.string :name

    t.timestamps null: false
  end

  create_table :club_members do |t|
    t.references :club
    t.references :user

    t.integer :role, null: false

    t.timestamps null: false
  end

  add_foreign_key :posts, :users
  add_foreign_key :posts, :levels
  add_foreign_key :comments, :posts
  add_foreign_key :comments, :users
  add_foreign_key :comments, :comments, column: :parent_comment_id
  add_foreign_key :account_histories, :accounts
  add_foreign_key :votes, :users
end
