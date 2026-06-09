# 📄 app/models/user_myfreet.rb
class UserMyfreet < ActiveRecord::Base
  # 1. 誰の所持データなのか（Userに所属している）
  belongs_to :user

  # 2. どの艦のデータなのか（Allfreetに所属している）
  belongs_to :allfreet, foreign_key: 'myfreet_id' # 👈 これで名前のズレを強制解決
end