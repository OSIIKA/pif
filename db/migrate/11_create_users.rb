# 11_create_users.rb（モデル確認済み）
# 1?_から始まるマイグレーションファイルは、ユーザー関連の動的処理を行うためのものです。
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      # ユーザー名
      t.string :name, null: false
      # メールアドレス
      t.string :mail, null: false
      # ログイン・認証
      t.string :password_digest, null: true
      t.string :uid
      t.string :provider
      # レベル・経験値管理
      t.integer :level, default: 1, null: false
      t.integer :exp, default: 0, null: false
      # 所属連盟
      t.integer :alliance_id
      t.integer :alliance_role, default: 0, null: false # 0: 一般, 1: 副盟主, 2: 盟主
      # ユーザーランク
      t.integer :user_lank_id, default: 1, null: false
      # t.string :info
    end
    add_index :users, [:provider, :uid], unique: true
  end
end