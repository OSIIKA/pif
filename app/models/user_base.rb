# 📄 app/models/user_base.rb
class UserBase < ActiveRecord::Base
  # 👤 「この基地データは、特定の1人のユーザーに所属しています」
  belongs_to :user
end