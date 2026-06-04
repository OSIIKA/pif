class CreateUserlanks < ActiveRecord::Migration[6.1]
  def change
    create_table :user_lanks do |t|
      t.string :name, null: false# ランク名
      t.text :text# ランク説明
      t.integer :event1, null: false# イベント参加権
      t.integer :event2, null: false# イベント参加権
      t.integer :required_exp, default: 0  # 必要経験値

      t.timestamps
    end
  end
end
