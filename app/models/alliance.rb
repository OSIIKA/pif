# 📄 app/models/alliance.rb
class Alliance < ActiveRecord::Base
  # メンバー一覧（User側の alliance_id と紐付く）
  has_many :users
  has_many :chats
  # 盟主（leader_id で User を参照）
  belongs_to :leader, class_name: "User", foreign_key: "leader_id"

  # 同盟名バリデーション
  validates :name, presence: true, allow_blank: false, uniqueness: true

  # 加入方式の人間向け表記
  def join_type_name
    case join_type
    when "public"   then "誰でも参加可能"
    when "approval" then "申請制"
    when "invite"   then "招待制"
    else "不明"
    end
  end

  # レベル表示
  def level_name
    "同盟Lv#{level}"
  end

  # 次レベル必要経験値（必要なら後で調整）
  def next_exp
    100 + (level * 50)
  end

  # 経験値加算＆レベルアップ
  def add_exp(amount)
    self.exp += amount
    level_up while exp >= next_exp
    save
  end

  def level_up
    self.exp -= next_exp
    self.level += 1
  end
end
