class User < ActiveRecord::Base
  has_many :comments
  has_one :dashboard

  validates :confirmed_at, presence: true
end
