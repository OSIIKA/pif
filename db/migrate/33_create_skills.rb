class CreateSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :effect_type, null: false
      t.integer :value, default: 0
      t.text :description
    end

  end
end
