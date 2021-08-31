class User < ApplicationRecord
  has_many :posts

  validates :email, presence: true
  validates :auth_token, presence: true
  validates :name, presence: true
end
