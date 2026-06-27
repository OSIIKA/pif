# 03_create_items.rb
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name, null: false # アイテム名
      t.text :description # アイテム説明
      t.integer :type, null: false # アイテムの種類（例: 0=紫鉄（ガチャ石）、1=ガチャチケ、2=その他数値アイテム、3=その他単品アイテム）
      t.integer :each_id, null: false # アイテムの個別識別ID
      t.integer :rarity, null: false # レアリティ（例: 1=普通、2=レア、3=超レアなど）
    end
  end
end
