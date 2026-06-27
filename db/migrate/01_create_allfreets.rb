# 01_create_allfreets.rb
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateAllfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :allfreets do |t|
      # 敵艦を検索するために暫定的に置いているカラム
      # 必要に応じて敵艦中間テーブルに移動する
      t.integer :stage
      # どの艦艇も持っている基本情報
      t.string :name
      t.integer :hp
      t.integer :max_hp
      t.integer :atk
      t.integer :speed
      t.integer :skill1_id
      t.integer :skill2_id
      t.integer :skill3_id
      t.integer :weapon1_id
      t.integer :weapon2_id
      t.integer :weapon3_id

      t.string :info

      t.integer :rarity, default: 1

      t.integer :normal, default: 0
      t.integer :rare, default: 0
      t.integer :limited, default: 0
      t.integer :story, default: 0
      t.integer :event, default: 0
    end
  end
end
