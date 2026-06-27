# 📄 app/models/user_myfreet.rb
class UserMyfreet < ActiveRecord::Base
  # 1. 誰の所持データなのか（Userに所属している）
  belongs_to :user
  # 2. どの艦のデータなのか（Allfreetに所属している）
  belongs_to :allfreet, foreign_key: 'myfreet_id' # 👈 これで名前のズレを強制解決
  # 艦艇スキル（多対多）
  has_many :user_myfreet_skills
  has_many :skills, through: :user_myfreet_skills

  # 艦艇にキャラと武装を直接載せる
  belongs_to :character, optional: true
  belongs_to :weapon, optional: true
end