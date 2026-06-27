# 📄 app/models/enemy_battleunit.rb
class EnemyBattleunit < ActiveRecord::Base
  # 敵艦は enemy_freets（動的辞書）を参照する
  belongs_to :flagship, class_name: "EnemyFreet", foreign_key: :flagship_id

  belongs_to :sub_ship_1, class_name: "EnemyFreet", foreign_key: :sub_ship_1_id, optional: true
  belongs_to :sub_ship_2, class_name: "EnemyFreet", foreign_key: :sub_ship_2_id, optional: true
  belongs_to :sub_ship_3, class_name: "EnemyFreet", foreign_key: :sub_ship_3_id, optional: true
  belongs_to :sub_ship_4, class_name: "EnemyFreet", foreign_key: :sub_ship_4_id, optional: true
  belongs_to :sub_ship_5, class_name: "EnemyFreet", foreign_key: :sub_ship_5_id, optional: true
  belongs_to :sub_ship_6, class_name: "EnemyFreet", foreign_key: :sub_ship_6_id, optional: true

  # 敵艦一覧（nil を除外）
  def ships
    [
      flagship,
      sub_ship_1,
      sub_ship_2,
      sub_ship_3,
      sub_ship_4,
      sub_ship_5,
      sub_ship_6
    ].compact
  end

  # 戦闘用ハッシュ（battle.js に渡す形式）
  def to_battle_hash
    {
      id: id,
      col: col,
      row: row,
      flagship: {
        id: flagship.id,
        hp: flagship.hp,
        max_hp: flagship.max_hp,
        atk: flagship.atk,
        skill: flagship.skill.name
      },
      sub_ships: ships.drop(1).map { |ship|
        {
          id: ship.id,
          hp: ship.hp,
          max_hp: ship.max_hp,
          atk: ship.atk,
          skill: ship.skill.name
        }
      }
    }
  end
end
