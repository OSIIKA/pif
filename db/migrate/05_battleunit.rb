class CreateBattleunit < ActiveRecord::Migration[6.1]
  def change
    create_table :battleunits do |t|
      t.string :name
      t.integer :hp
      t.integer :atk
      t.string :info
    end
  end
end
