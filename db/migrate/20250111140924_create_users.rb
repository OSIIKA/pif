class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :mail
      t.string :password_digest, null: false # 必須: password_digestに変更
      t.integer :level
      t.integer :exp
      # t.string :info
      # t.integer :user
    end
    # add_index :users, :mail, unique: true
  end
end
#class ApplicationRecord < ActiveRecord::Base
#    self.abstract_class = true
#end
#class User < ApplicationRecord
#    has_secure_password
#    validates :name, presence: true
#    validates :mail, presence: true, fonmat: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
#    validates :password, length: { minimum: 6 }
#end