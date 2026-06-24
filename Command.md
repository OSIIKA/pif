Gemfile更新
bundle install

DB更新
dropdb -p 5433 -U postgres pif_development
createdb -p 5433 -U postgres pif_development
rake db:migrate
rake db:seed

これからのapp.rb
①Macの場合
機密情報につき削除
②Windowsの場合
機密情報につき削除


㊟注意：拡大率100％では正常に表示されない：Ctrl+すべし
bundle exec rake db:create_migration NAME=create_userlanks
bundle exec rake db:create_migration NAME=create_user_myfreets
bundle exec rake db:create_migration NAME=create_user_myfreet_weapons

class CreateUserMyfreets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_myfreets do |t|
      t.integer :user_id, null: false
      t.integer :myfreet_id, null: false
      t.integer :level, default: 1
      t.integer :exp, default: 0

      t.timestamps
    end

    add_index :user_myfreets, :user_id
    add_index :user_myfreets, :myfreet_id
  end
end



users.level → user_lanks.id
①app/models/user.rb
class User < ActiveRecord::Base
  belongs_to :user_lank, foreign_key: :level, optional: true
end
②app/models/user_lank.rb
class UserLank < ActiveRecord::Base
  has_many :users, foreign_key: :level
end


users ↔ user_myfreets ↔ myfreets
①app/models/user.rb
class User < ActiveRecord::Base
  has_many :user_myfreets
  has_many :myfreets, through: :user_myfreets
end
②app/models/myfreet.rb
class Myfreet < ActiveRecord::Base
  has_many :user_myfreets
  has_many :users, through: :user_myfreets
end
③app/models/user_myfreet.rb
class UserMyfreet < ActiveRecord::Base
  belongs_to :user
  belongs_to :myfreet
end
