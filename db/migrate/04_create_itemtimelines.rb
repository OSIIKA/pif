class CreateItemtimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :itemtimelines do |t|
      t.integer :big_type, null: false # ガチャボーナス、ログインボーナス、イベントボーナス、クエスト報酬などの大分類
      t.integer :small_type, null: false # それぞれの細かな分類
      t.integer :step, null: false # その何回目か
      t.integer :item_id, null: false # どのアイテムを配布するか
      t.integer :count, null: false # 配布数量
    end

    # よく検索する項目にはインデックスを貼ると爆速になります
    add_index :itemtimelines, :user_id
    add_index :itemtimelines, :item_id
  end
end
