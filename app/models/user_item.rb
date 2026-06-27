# 📄 app/models/user_item.rb
class UserItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
end