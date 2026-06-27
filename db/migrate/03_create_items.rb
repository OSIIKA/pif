# 03_create_items.rb（モデル確認済み）
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      # アイテム名
      t.string :name, null: false
      # 説明文
      t.text :description
      # アイテムカテゴリ
      # app/models/item.rbを参照
      t.integer :category, null: false
      # レアリティ
      # app/models/item.rbを参照
      t.integer :rarity, null: false
      # 念の為の timestamps
      t.timestamps
    end
  end
end
