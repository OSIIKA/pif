# 31_create_enemy_freets.rb（モデル確認済み）
# 3?_から始まるマイグレーションファイルは、敵関連の動的処理を行うためのものです。
class CreateEnemyFreets < ActiveRecord::Migration[6.1]
  def change
    create_table :enemy_freets do |t|
      t.integer :allfreet_id, null: false
      t.integer :level, default: 1, null: false
      t.timestamps
    end
  end
end
