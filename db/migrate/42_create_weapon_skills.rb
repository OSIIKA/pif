class CreateWeaponSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :weapon_skills do |t|
      t.integer :weapon_id, null: false
      t.integer :skill_id, null: false
      t.integer :level, default: 1
      t.integer :exp, default: 0
      t.timestamps
    end
  end
end
