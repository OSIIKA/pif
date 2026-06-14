class CreateItemtimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :itemtimelines do |t|
      t.integer :big_type, null: false # ガチャボーナス、ログインボーナス、イベントボーナス、クエスト報酬などの大分類
      t.integer :small_type, null: false # それぞれの細かな分類
      t.integer :step, null: false # その何回目か
      # ⭕️ 追加：二段構えの身元引受人カラム
      t.integer :item_type, null: false
      t.integer :item_each_id, null: false
      t.integer :count, null: false # 配布数量
    end

    # よく検索する項目にはインデックスを貼ると爆速になります
    add_index :itemtimelines, :item_id
  end
end
