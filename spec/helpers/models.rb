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

class PrivatePost < Post
  belongs_to :level
end

class Level < ActiveRecord::Base
  has_many :private_posts
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :parent_comment, class_name: "Comment"
  has_and_belongs_to_many :mentioned_users,
                          join_table: :user_mentions,
                          class_name: "User"
  has_many :votes, as: :voteable
  has_many :replies, class_name: "Comment", foreign_key: :parent_comment_id

  scope :threads, -> { where(parent_comment_id: nil) }
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
