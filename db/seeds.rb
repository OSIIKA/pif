# 📄 db/seeds.rb の1行目に追記
require_relative '../app'
# ===========================
# ユーザー（システム）データ
# ===========================
# すでに存在する場合はスキップし、なければ ID: 1で作成する
User.find_or_create_by!(id: 1) do |u|
  u.name = "システム"
  u.mail = "system@example.com" # 👈 email から mail に修正
  # 👈 毎回、絶対に予測不可能なランダムな文字列（64文字）を生成して設定
  random_pass = SecureRandom.hex(32) 
  u.password = random_pass
  u.password_confirmation = random_pass
  u.level = 1
  u.exp = 0
  u.alliance_id = nil
  u.alliance_role = 0
end
# ===========================
# アイテムデータ
# ===========================
Item.find_or_create_by!(name: "紫鉄", type: 0, rarity: 1) do |item|
  item.description = "ガチャを引くための基本アイテム。"
end
Item.find_or_create_by!(name: "ガチャチケット", type: 1, rarity: 2) do |item|
  item.description = "ガチャを1回引くことができるチケット。"
end
# ===========================
# 敵データ
# ===========================
# ステージ1の敵（2体）
Allfreet.find_or_create_by!(stage: 1, name: "敵1", hp: 100, max_hp: 100, atk: 25, info: "てんぷれ", normal: 100, rare: 100, rarity: 1)
Allfreet.find_or_create_by!(stage: 1, name: "敵2", hp: 120, max_hp: 120, atk: 30, info: "てんぷれ", normal: 100, rare: 100, rarity: 1)
# ステージ2の敵（3体）
Allfreet.find_or_create_by!(stage: 2, name: "敵3", hp: 150, max_hp: 150, atk: 40, info: "てんぷれ", normal: 100, rare: 100, rarity: 1)
Allfreet.find_or_create_by!(stage: 2, name: "敵4", hp: 150, max_hp: 150, atk: 40, info: "てんぷれ", normal: 100, rare: 100, rarity: 1)
Allfreet.find_or_create_by!(stage: 2, name: "敵5", hp: 200, max_hp: 200, atk: 50, info: "てんぷれ", normal: 100, rare: 100, rarity: 1)
# ===========================
# 敵・味方データ
# ===========================
Allfreet.find_or_create_by!(name: "味方1", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと", normal: 100, rare: 100, rarity: 1)
Allfreet.find_or_create_by!(name: "味方2", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと", normal: 40, rare: 150, rarity: 2)
Allfreet.find_or_create_by!(name: "味方3", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと", normal: 20, rare: 40, rarity: 3)
# ===========================
# ストーリーデータ
# ===========================
# 第0話
#episode0 = [
#  ["システム", "＜紫星・磯秋より、紫星・Userへ、メッセージを送信します。＞"],
#  ["磯秋", "「あなたはもう、こちらに向かっているのでしょうか…」"],
#  ["システム", "＜時間切れになりました。メッセージを終了します。＞"],
#  ["System", "BattleStart", 1],
#  ["？？？", "てすと"],
#  ["System", "BattleStart", 2],
#  ["？？？", "てすと"]
  # ここに続きの文章を追加していく
#]

#episode0.each_with_index do |(name, text, battle), i|
#  Story.create(episode: 0, step: i+1, name: name, text: text, style: 0, battle: battle || 0)
#end
# 第1話
#episode1 = [
#  ["ナレーション", "＜集結編第1話　未知の通信システム＞"],
#  ["？？？", "てすと"],
#  ["？？？", "てすと"],
#  ["？？？", "てすと"]
#  # ここに続きの文章を追加していく
#]

#episode1.each_with_index do |(name, text, battle), i|
#  Story.create(episode: 1, step: i+1, name: name, text: text, style: 0, battle: battle || 0)
#end
# ==========================================
# 🚨 PostgreSQLの自動採番カウンター（シーケンス）を現在の最大IDに同期する
# ==========================================
if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
  # usersテーブルのカウンターを、現在の最大ID（1）の次（2）に強制進業する
  ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1))")
  # 他のテーブルも同様に必要に応じてシーケンスをリセットする
  ActiveRecord::Base.connection.execute("SELECT setval('myfreets_id_seq', COALESCE((SELECT MAX(id) FROM myfreets), 1))")
  ActiveRecord::Base.connection.execute("SELECT setval('allfreets_id_seq', COALESCE((SELECT MAX(id) FROM allfreets), 1))")
#  ActiveRecord::Base.connection.execute("SELECT setval('stories_id_seq', COALESCE((SELECT MAX(id) FROM stories), 1))")
end