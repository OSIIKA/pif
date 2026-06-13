class Usersteps < ActiveRecord::Base
  # 👤 「この進捗データは、特定の1人のユーザーに所属しています」という宣言
  belongs_to :user
end