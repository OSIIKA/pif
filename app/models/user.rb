class User < ActiveRecord::Base
  belongs_to :user_lank, foreign_key: :level, optional: true
end
