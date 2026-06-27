class Allfreet < ActiveRecord::Base
  has_many :allfreet_skills
  has_many :skills, through: :allfreet_skills
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