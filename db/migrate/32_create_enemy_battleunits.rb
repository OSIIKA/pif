# 32_create_enemy_battleunits.rb（モデル確認済み）
# 3?_から始まるマイグレーションファイルは、敵関連の動的処理を行うためのものです。
class CreateEnemyBattleunits < ActiveRecord::Migration[6.1]
  def change
    create_table :enemy_battleunits do |t|
      t.integer :battle_stage_id, null: false
      t.integer :col, null: false # 敵のX座標
      t.integer :row, null: false # 敵のY座標
      t.integer :flagship_id, null: false      # 敵旗艦 (enemy_freets.id)
      t.integer :sub_ship_1_id    # 敵随伴1 (enemy_freets.id)
      t.integer :sub_ship_2_id
      t.integer :sub_ship_3_id
      t.integer :sub_ship_4_id
      t.integer :sub_ship_5_id
      t.integer :sub_ship_6_id
      t.timestamps
    end
  end
end
