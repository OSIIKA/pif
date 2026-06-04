class CreateMyfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :myfreets do |t|
      t.string :name
      t.integer :hp
      t.integer :max_hp
      t.integer :atk
      t.string :info
    end
  end
end
