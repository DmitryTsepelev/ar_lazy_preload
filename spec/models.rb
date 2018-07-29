# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_one :account
  has_many :comments_on_posts, through: :posts, source: :comments
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end

class Account < ActiveRecord::Base
  belongs_to :user
end
