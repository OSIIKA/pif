class CreateCharacterSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :character_skills do |t|
      t.integer :character_id, null: false
      t.integer :skill_id, null: false
      t.integer :level, default: 1
      t.integer :exp, default: 0
      t.timestamps
    end
  end
end
