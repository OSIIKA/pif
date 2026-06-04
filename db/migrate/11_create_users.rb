class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :mail
      t.string :password_digest, null: true
      t.integer :level, default: 1, null: false
      t.integer :exp, default: 0, null: false
      t.integer :alliance_id
      t.integer :user_lank_id, default: 1, null: false
      # t.string :info
      t.string :uid
      t.string :provider
    end
    add_index :users, [:provider, :uid], unique: true
  end
end