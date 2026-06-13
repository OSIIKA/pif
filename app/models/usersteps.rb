class Usersteps < ActiveRecord::Base
  # 🟢 ここを追記：ActiveRecordの自動推測を無視して、本物のテーブル名を強制指定する
  self.table_name = "usersteps"
  # 👤 「この進捗データは、特定の1人のユーザーに所属しています」という宣言
  belongs_to :user
end