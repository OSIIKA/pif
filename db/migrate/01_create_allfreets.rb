class CreateAllfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :allfreets do |t|
      t.integer :stage
      t.string :name
      t.integer :hp
      t.integer :max_hp
      t.integer :atk
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
