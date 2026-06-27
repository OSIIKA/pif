# 📄 app/models/itemtimeline.rb
class Itemtimeline < ActiveRecord::Base
  # 辞書の分類名（必要なら拡張）
  def big_type_name
    case big_type
    when 1 then "ガチャボーナス"
    when 2 then "ログインボーナス"
    when 3 then "イベント報酬"
    when 4 then "クエスト報酬"
    else "その他"
    end
  end

  def small_type_name
    "分類#{small_type}"
  end

  # 辞書参照（user_items と同じ方式）
  def dictionary
    case item_type
    when 0 then Allfreet.find(item_each_id)
    when 1 then Character.find(item_each_id)
    when 2 then Weapon.find(item_each_id)
    when 3 then Item.find(item_each_id)
    end
  end
end