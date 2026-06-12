class Item < ActiveRecord::Base
  # 1つのアイテムは、多くの中間テーブル（ユーザー所持データ）を持ちます
  has_many :user_items
  # 中間テーブル（user_items）を経由して、多くのユーザーと紐付いています
  has_many :users, through: :user_items
end