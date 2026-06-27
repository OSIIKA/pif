# 📄 app/models/user_battleunit.rb
class UserBattleunit < ActiveRecord::Base
  # 👤 「この艦隊データは、特定の1人のユーザーに所属しています」
  belongs_to :user
end