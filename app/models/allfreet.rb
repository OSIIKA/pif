class Allfreet < ActiveRecord::Base
  belongs_to :skill1, class_name: 'Skill', foreign_key: 'skill1_id', optional: true
  belongs_to :skill2, class_name: 'Skill', foreign_key: 'skill2_id', optional: true
  belongs_to :skill3, class_name: 'Skill', foreign_key: 'skill3_id', optional: true

  # 🟢 数字をレア度の文字列に変換する翻訳機
  def rarity_text
    case rarity
    when 1 then "N"
    when 2 then "R"
    when 3 then "SR"
    else "???" # 万が一想定外の数字が入ったときの保険
    end
  end
end