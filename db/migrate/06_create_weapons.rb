# 06_create_weapons.rb（モデル確認済み）
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateWeapons < ActiveRecord::Migration[6.1]
  def change
    create_table :weapons do |t|
      t.string  :name, null: false
      t.text    :description
      t.integer :rarity, null: false
      t.integer :price, default: 0, null: false

      # 1武器1スキル
      t.integer :skill_id, null: false

      t.timestamps
    end
  end
end
