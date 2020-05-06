class Comment < ActiveRecord::Base
  has_many :resource_files
end
