# 📄 app/models/item.rb
class Item < ActiveRecord::Base
  # カテゴリ名を返す（必要なら拡張）
  def category_name
    case category
    when 1 then "紫鉄（石）"
    when 2 then "ガチャチケット"
    when 3 then "素材"
    else "その他"
    end
  end
  # レアリティ表記（必要なら拡張）
  def rarity_text
    case rarity
    when 1 then "N"
    when 2 then "R"
    when 3 then "SR"
    else "???"
    end
  end
  # 1つのアイテムは、多くの中間テーブル（ユーザー所持データ）を持ちます
  has_many :user_items
  # 中間テーブル（user_items）を経由して、多くのユーザーと紐付いています
  has_many :users, through: :user_items
end