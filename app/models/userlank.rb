class UserLank < ActiveRecord::Base
  has_many :users, foreign_key: :level
end
