class Comment < ActiveRecord::Base
  has_many :resource_files
  belongs_to :user
end
