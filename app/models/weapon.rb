# 📄 app/models/weapon.rb
class Weapon < ActiveRecord::Base
  # 1武器1スキル
  belongs_to :skill

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
