# 📄 app/models/enemy_freet.rb
class EnemyFreet < ActiveRecord::Base
  # 敵艦は辞書 allfreets を参照する
  belongs_to :dictionary, class_name: "Allfreet", foreign_key: :allfreet_id

  # 辞書ステータスをレベル補正して返す
  def hp
    (dictionary.hp * level_multiplier).to_i
  end

  def max_hp
    (dictionary.max_hp * level_multiplier).to_i
  end

  def atk
    (dictionary.atk * level_multiplier).to_i
  end

  def speed
    dictionary.speed
  end

  # レベル補正（必要なら後で調整）
  def level_multiplier
    1.0 + (level - 1) * 0.1
  end

  # 敵艦のスキル（辞書側の単一スキル）
  def skill
    dictionary.skill
  end

  # 戦闘用のハッシュ（battle.js に渡す形式）
  def to_battle_hash
    {
      id: id,
      name: dictionary.name,
      hp: hp,
      max_hp: max_hp,
      atk: atk,
      speed: speed,
      skill: skill.name
    }
  end
end
