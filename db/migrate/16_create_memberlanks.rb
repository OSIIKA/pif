class CreateMemberlanks < ActiveRecord::Migration[6.1]
  def change
    create_table :member_lanks do |t|
      t.string :name, null: false# ランク名
      t.text :text# ランク説明
      t.timestamps
    end
  end
end
