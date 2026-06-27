# 📄 app/models/user_battleunit.rb
class UserBattleunit < ActiveRecord::Base
  # 👤 「この艦隊データは、特定の1人のユーザーに所属しています」
  belongs_to :user
  # 艦艇（実体）を参照する
  belongs_to :flagship, class_name: "UserItem", optional: true

  belongs_to :sub_ship_1, class_name: "UserItem", optional: true
  belongs_to :sub_ship_2, class_name: "UserItem", optional: true
  belongs_to :sub_ship_3, class_name: "UserItem", optional: true
  belongs_to :sub_ship_4, class_name: "UserItem", optional: true
  belongs_to :sub_ship_5, class_name: "UserItem", optional: true
  belongs_to :sub_ship_6, class_name: "UserItem", optional: true

  # 艦隊名（UI用）
  def fleet_name
    "第#{fleet_number}艦隊"
  end

  # 艦艇一覧（nil を除外）
  def ships
    [
      flagship,
      sub_ship_1,
      sub_ship_2,
      sub_ship_3,
      sub_ship_4,
      sub_ship_5,
      sub_ship_6
    ].compact
  end

  # 艦艇辞書（allfreets）を返す
  def freet_dictionaries
    ships.map(&:dictionary)
  end
end