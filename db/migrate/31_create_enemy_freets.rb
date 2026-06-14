class CreateEnemyFreets < ActiveRecord::Migration[6.1]
  def change
    create_table :enemy_freets do |t|
      t.integer :allfreet_id, null: false
      t.integer :level, default: 1, null: false
      t.timestamps
    end
  end
end
