# 04_create_itemtimelines.rb（モデル確認済み）
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateItemtimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :itemtimelines do |t|
      t.integer :big_type, null: false # ガチャボーナス、ログインボーナス、イベントボーナス、クエスト報酬などの大分類
      t.integer :small_type, null: false # それぞれの細かな分類
      t.integer :step, null: false # その何回目か
      # 報酬の名前を辞書側に持たせる
      t.string :reward_name
      # ⭕️ 追加：二段構えの身元引受人カラム
      t.integer :item_type, null: false
      t.integer :item_each_id, null: false
      t.integer :count, null: false # 配布数量
      # イベントやキャンペーンの ON/OFFについては、今後イベント辞書を作り対応する予定
    end

    # よく検索する項目にはインデックスを貼ると爆速になります
    add_index :itemtimelines, [:item_type, :item_each_id]
  end
end
