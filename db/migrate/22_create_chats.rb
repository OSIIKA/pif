# 22_create_chats.rb（モデル確認済み）
class CreateChats < ActiveRecord::Migration[6.1]
  def change
    create_table :chats do |t|
      t.integer :user_id, null: false     # 発言者のユーザーID
      t.string :body, null: false         # 発言内容（メッセージ）
      t.string :category, null: false     # チャットの種類（"global" または "alliance"）
      t.integer :alliance_id              # 同盟チャットの場合のみ、どの同盟かのID（全体チャットなら空っぽ）

      t.timestamps # 発言時間を記録するために必須！
    end

    # 検索を爆速にするためのインデックス
    add_index :chats, :category
    add_index :chats, :alliance_id
  end
end
