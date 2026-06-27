# 📄 app/models/chat.rb
class Chat < ActiveRecord::Base
  # 1. チャットの発言は、特定の1人のユーザーに所属している
  belongs_to :user
  # 2. チャットの発言は、どこかの同盟に紐づいている（全体チャットの時は無しでもOK）
  belongs_to :alliance, optional: true
  # 💡 チャットがデータベースに保存された「直後」に自動で発動する呪文（コールバック）
  after_create :cleanup_old_chats
  # 3. 空白の送信や、長すぎる文章（例：100文字以上）を弾くバリデーション
  validates :body, presence: true, allow_blank: false, length: { maximum: 100 }
  validates :category, inclusion: { in: %w[global alliance] } # この2種類以外は許さない
  # 4. 古いチャットを自動で消すためのメソッド
  private

  def cleanup_old_chats
    if category == 'alliance' && alliance_id.present?
      # 🛡️ 同盟チャットの場合：各同盟ごとに最新200件を残す
      allowed_count = 200
      chats_to_delete = Chat.where(alliance_id: alliance_id, category: 'alliance')
                            .order(created_at: :desc)
                            .offset(allowed_count)
      
      chats_to_delete.delete_all if chats_to_delete.any?

    elsif category == 'global'
      # 🛡️ 全体チャットの場合：ゲーム全体で最新500件を残す（件数は自由に調整OK）
      allowed_count = 500
      chats_to_delete = Chat.where(category: 'global')
                            .order(created_at: :desc)
                            .offset(allowed_count)
      
      chats_to_delete.delete_all if chats_to_delete.any?
    end
  end
end