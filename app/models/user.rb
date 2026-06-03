class User < ActiveRecord::Base
  # bcryptとpassword_digestを連動させる魔法の1行
  has_secure_password
  # 既存のリレーション（そのまま残します）
  belongs_to :user_lank, foreign_key: :level, optional: true
  # セキュリティシステムとバリデーションの追加
  # ユーザー名のチェック
  validates :name, presence: true, uniqueness: true
  # メールアドレスのチェック
  validates :mail, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  # パスワードのチェック
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
