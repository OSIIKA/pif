# 03_create_items.rb
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
      # 1→紫鉄（石）
      # 2→ガチャチケ
      # 3→素材など
      t.integer :category, null: false
      # レアリティ
      t.integer :rarity, null: false
      t.timestamps
    end
  end
end
