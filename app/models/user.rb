# 📄 app/models/user.rb
class User < ActiveRecord::Base
  # bcryptとpassword_digestを連動させる魔法の1行
  has_secure_password
  # ユーザーは1つのユーザーステップ（進捗）を持つ
  has_one :usersteps, class_name: "Usersteps", dependent: :destroy
  # ユーザーは1つのユーザーベース（基地）を持つ
  has_one :user_base, dependent: :destroy
  # ユーザーはたくさんのチャット発言を持つ
  has_many :chats, dependent: :destroy
  # ユーザーはたくさんの艦隊配置を持つ
  has_many :user_battleunits, dependent: :destroy
  # ユーザーはたくさんのアイテム所持データを持つ
  has_many :user_items, dependent: :destroy
  # アイテムとの多対多の関係を中間テーブル（user_items）を経由して定義
  has_many :items, through: :user_items

  # ユーザーはどこかの同盟に所属する（無所属もOKにするため optional: true）
  belongs_to :alliance, optional: true
  # セキュリティシステムとバリデーションの追加
  # ユーザー名のチェック
  validates :name, presence: true, allow_blank: false, uniqueness: true
  # メールアドレスのチェック
  validates :mail, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  # パスワードのチェック
  # 新規登録時であり、かつ「外部認証のID（uid）がない」または「パスワードが直接入力されている」場合のみ、6文字以上の制限をかける
  validates :password, length: { minimum: 6 }, if: -> { new_record? && (password.present? || uid.nil?) }, on: :create
  # 💡 追加：同盟内の役職名を数字から判定して返す
  def alliance_role_name
    case self.alliance_role
    when 4
      "👑 盟主"
    when 3
      "⚔️ 副盟主"
    when 2
      "🛡️ メンバー"
    when 1
      "✉️ 申請中"
    else
      "無所属"
    end
  end
  def rank_name
    case level
    when 1..10  then "ブロンズ"
    when 11..20 then "シルバー"
    when 21..30 then "ゴールド"
    else "プラチナ"
    end
  end
  # 紫鉄アイテムの所持数を返す
  def iron_count
    # 紫鉄の辞書（Item辞書）
    iron_master = Item.find_by(category: 0, rarity: 1)
    return 0 unless iron_master

    # UserItem から紫鉄を検索
    user_items.where(object_id: 3, item_id: iron_master.id).sum(:count)
  end
end
