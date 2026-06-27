# 02_create_stories.rb
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateStories < ActiveRecord::Migration[6.1]
  def change
    create_table :stories do |t|
      t.integer :episode, null: false
      t.integer :step,    null: false
      t.string  :name
      t.text    :text,    null: false
      t.integer :style,   default: 0
      t.integer :battle,   default: 0
    end
  end
end
