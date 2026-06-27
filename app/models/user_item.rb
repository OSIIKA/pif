# 📄 app/models/user_item.rb
class UserItem < ActiveRecord::Base
  belongs_to :user

  # 辞書参照（object_id に応じて切り替え）
  def dictionary
    case object_id
    when 0 then Allfreet.find(item_id)   # 艦艇辞書
    when 1 then Character.find(item_id)  # キャラ辞書
    when 2 then Weapon.find(item_id)     # 武器辞書
    when 3 then Item.find(item_id)       # 汎用アイテム辞書
    else
      raise "Unknown object_id: #{object_id}"
    end
  end

  # 艦艇個体が装備している武器（user_items）
  belongs_to :weapon_item,
             class_name: "UserItem",
             foreign_key: :weapon_id,
             optional: true

  # 艦艇個体が搭載しているキャラ（user_items）
  belongs_to :character_item,
             class_name: "UserItem",
             foreign_key: :character_id,
             optional: true

  # 艦艇個体かどうか
  def freet?
    object_id == 0
  end

  # キャラ個体かどうか
  def character?
    object_id == 1
  end

  # 武器個体かどうか
  def weapon?
    object_id == 2
  end

  # 汎用アイテムかどうか
  def item?
    object_id == 3
  end

  # 辞書のスキルを返す（艦・キャラ・武器は単一スキル）
  def skill
    dictionary.skill
  end

  # 艦艇個体が持つ全スキル（艦＋武器＋キャラ）
  def all_skills
    return [] unless freet?

    [
      dictionary.skill,
      weapon_item&.dictionary&.skill,
      character_item&.dictionary&.skill
    ].compact
  end
end
