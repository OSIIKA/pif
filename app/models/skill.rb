# 📄 app/models/skill.rb
class Skill < ActiveRecord::Base
  # スキルを持つ艦艇・キャラ・武器（辞書側）
  has_many :allfreets
  has_many :characters
  has_many :weapons

  # 効果タイプを人間向けに変換（必要なら拡張）
  def effect_name
    case effect_type
    when "buff_hp"     then "HP上昇"
    when "buff_atk"    then "攻撃力上昇"
    when "buff_speed"  then "速度上昇"
    when "heal"        then "回復"
    when "cleanse"     then "状態異常解除"
    when "special"     then "特殊効果"
    else "不明効果"
    end
  end
end
