class CreateUserMyfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_myfreets do |t|
      t.integer :user_id
      t.integer :myfreet_id
      t.integer :level
      t.integer :exp
      t.integer :skill1_id
      t.integer :skill2_id
      t.integer :skill3_id
      t.integer :weapon1_id
      t.integer :weapon2_id
      t.integer :weapon3_id
    end
  end
end
