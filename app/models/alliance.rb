class Alliance < ActiveRecord::Base
  # 1. 1つの同盟には、たくさんのユーザー（メンバー）が所属する関係（1対多）
  has_many :users

  # 2. 盟主（リーダー）は、Userの中の特別な1人であるという関係
  # テーブルの leader_id を使って User モデルを探しに行きます
  belongs_to :leader, class_name: 'User', foreign_key: 'leader_id'

  # 3. 同盟名のバリデーション（空白不可、名前の重複不可）
  validates :name, presence: true, allow_blank: false, uniqueness: true
end