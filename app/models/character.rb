# 📄 app/models/character.rb
class Character < ActiveRecord::Base
  # 所属名（必要なら拡張）
  def affiliation_name
    case affiliation
    when 1 then "紫鉄艦隊"
    when 2 then "六色連星"
    when 3 then "セントラスノル"
    else "不明勢力"
    end
  end

  # レアリティ表記
  def rarity_text
    case rarity
    when 1 then "N"
    when 2 then "R"
    when 3 then "SR"
    else "???"
    end
  end
end