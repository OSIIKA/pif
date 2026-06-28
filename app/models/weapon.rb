# 📄 app/models/weapon.rb
class Weapon < ActiveRecord::Base
  # 1武器1スキル
  belongs_to :skill
  # カテゴリ名を返す（必要なら拡張）
  def category_name
    case category
    when 1 then "通常武器"
    when 2 then "ガチャ武器"
    when 3 then "イベント武器"
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
end
