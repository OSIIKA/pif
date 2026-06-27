# 12_create_user_battleunits.rb（モデル確認済み）
# 1?_から始まるマイグレーションファイルは、ユーザー関連の動的処理を行うためのものです。
class CreateUserBattleunits < ActiveRecord::Migration[6.1]
  def change
    create_table :user_battleunits do |t|
      t.integer :user_id, null: false        # 👤 どのユーザーの艦隊か
      t.integer :fleet_number, null: false   # 🔢 何番目の艦隊か（1 = 第一艦隊、6 = 第六艦隊）
      
      # 🚩 旗艦枠（1隻）
      t.integer :flagship_id                 # 所持している艦船のユニークID
      
      # ⚓ 随伴艦枠（6隻）
      t.integer :sub_ship_1_id
      t.integer :sub_ship_2_id
      t.integer :sub_ship_3_id
      t.integer :sub_ship_4_id
      t.integer :sub_ship_5_id
      t.integer :sub_ship_6_id

      t.timestamps
    end
    
    # 「ユーザーID」と「艦隊番号」の組み合わせにインデックスを張る（検索爆速化＆重複防止）
    add_index :user_battleunits, [:user_id, :fleet_number], unique: true
  end
end
