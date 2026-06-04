class User < ActiveRecord::Base
  # bcryptとpassword_digestを連動させる魔法の1行
  has_secure_password
  # 既存のリレーション（そのまま残します）
  belongs_to :user_lank, foreign_key: :level, optional: true
  # セキュリティシステムとバリデーションの追加
  # ユーザー名のチェック
  validates :name, presence: true, allow_blank: false, uniqueness: true
  # メールアドレスのチェック
  validates :mail, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  # パスワードのチェック
  # 新規登録時であり、かつ「外部認証のID（uid）がない」または「パスワードが直接入力されている」場合のみ、6文字以上の制限をかける
  validates :password, length: { minimum: 6 }, if: -> { new_record? && (password.present? || uid.nil?) }, on: :create
end
