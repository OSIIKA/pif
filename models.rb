require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection
class User < ActiveRecord::Base
  has_secure_password
  has_many :user_myfreets
  has_many :myfreets, through: :user_myfreets
end
class Myfreet < ActiveRecord::Base
  has_many :user_myfreets
  has_many :users, through: :user_myfreets
end
class Enemyfreet < ActiveRecord::Base
end
class Battleunit < ActiveRecord::Base
end
class Story < ActiveRecord::Base
  self.table_name = "storys"
end
class UserMyfreet < ActiveRecord::Base
  belongs_to :user
  belongs_to :myfreet
end
# class User < ActiveRecord::Base
# end
# # ログイン周り
# class ApplicationRecord < ActiveRecord::Base
#     self.abstract_class = true
# end


