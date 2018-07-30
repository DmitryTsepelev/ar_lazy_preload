# frozen_string_literal: true

class User < ActiveRecord::Base
  has_one :account
  has_one :account_history, through: :account

  has_many :posts
  has_many :comments
  has_many :comments_on_posts, through: :posts, source: :comments

  def vote_for(voteable)
    voteable.votes.create(user: self)
  end
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :votes, as: :voteable
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  has_and_belongs_to_many :mentioned_users,
                          join_table: :user_mentions,
                          class_name: "User"
  has_many :votes, as: :voteable
end

class Account < ActiveRecord::Base
  belongs_to :user
  has_one :account_history
end

class AccountHistory < ActiveRecord::Base
  belongs_to :account
end

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :voteable, polymorphic: true
end
