# 05_create_characters.rb（モデル確認済み）
# 0?_から始まるマイグレーションファイルは、データベースの初期設定を行うためのものです。
# これにはUserなどと接続する外部キーは付属せず、必ず最初に実行し、辞書目的でのみ使用されます。
class CreateCharacters < ActiveRecord::Migration[6.1]
  def change
    create_table :characters do |t|
      t.string  :name, null: false        # キャラ名
      t.text    :bio                      # 経歴・プロフィール
      t.integer :affiliation, null: false # 所属（数値→モデルで文字に変換）
      t.integer :rarity, null: false      # レアリティ（ガチャ用）
      # 1キャラ1スキル（辞書に直付け）
      t.integer :skill_id, null: false
    end
  end
end
