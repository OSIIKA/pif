class CreateEnemyfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :enemyfreets do |t|
      t.string :name
      t.integer :hp
      t.integer :max_hp
      t.integer :atk
      t.string :info
    end
  end
end
