# 📄 app/models/user_base.rb
class UserBase < ActiveRecord::Base
  belongs_to :user

  # 配置キャラ（user_items のキャラ個体）
  belongs_to :slotted_character_1,
             class_name: "UserItem",
             foreign_key: :slotted_character_1_id,
             optional: true

  belongs_to :slotted_character_2,
             class_name: "UserItem",
             foreign_key: :slotted_character_2_id,
             optional: true

  belongs_to :slotted_character_3,
             class_name: "UserItem",
             foreign_key: :slotted_character_3_id,
             optional: true

  belongs_to :slotted_character_4,
             class_name: "UserItem",
             foreign_key: :slotted_character_4_id,
             optional: true

  # 配置キャラ一覧（nil を除外）
  def slotted_characters
    [
      slotted_character_1,
      slotted_character_2,
      slotted_character_3,
      slotted_character_4
    ].compact
  end

  # HQ レベル名（必要なら拡張）
  def hq_name
    "司令部 Lv#{hq_level}"
  end

  # 生産施設レベル名
  def production_name
    "紫鉄生産施設 Lv#{production_level}"
  end
end
