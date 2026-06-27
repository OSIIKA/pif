# 14_create_user_bases.rb（モデル確認済み）
# 1?_から始まるマイグレーションファイルは、ユーザー関連の動的処理を行うためのものです。
class CreateUserBases < ActiveRecord::Migration[6.1]
  def change
    create_table :user_bases do |t|
      t.integer :user_id, null: false              # 👤 どのユーザーの基地か
      t.integer :hq_level, default: 1              # 🏢 司令部（本拠地）レベル
      t.integer :production_level, default: 1      # 🔩 紫鉄生産施設レベル
      
      # 👥 配置キャラクター枠（とりあえず最大4人配置できるようにID枠を4つ用意）
      t.integer :slotted_character_1_id
      t.integer :slotted_character_2_id
      t.integer :slotted_character_3_id
      t.integer :slotted_character_4_id

      t.timestamps
    end
    add_index :user_bases, :user_id, unique: true
  end
end
