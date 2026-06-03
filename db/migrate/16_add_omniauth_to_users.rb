class CreateAddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    # 1. 外部認証用のカラム（どのサービスで、どのIDか）をusersテーブルに追加
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    # 2. 既存のパスワード（password_digest）を「空でもOK(null: true)」に変更
    change_column_null :users, :password_digest, true

    # 3. ログイン時の検索を爆速にし、同じアカウントが重複登録されるのを防ぐ
    add_index :users, [:provider, :uid], unique: true
  end
end
