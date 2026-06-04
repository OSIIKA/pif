class CreateUserMyfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_myfreets do |t|
      t.integer :user_id
      t.integer :myfreet_id
      t.integer :level
      t.integer :exp
    end
  end
end
