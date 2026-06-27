# 07_create_skills.rb（モデル確認済み）
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :effect_type, null: false
      t.integer :value, default: 0
      t.text :description
    end

  end
end
