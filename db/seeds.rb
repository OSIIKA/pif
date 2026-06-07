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
# 敵データ
# ===========================
# ステージ1の敵（2体）
Enemyfreet.create(stage: 1, name: "敵1", hp: 100, max_hp: 100, atk: 25, info: "てんぷれ")
Enemyfreet.create(stage: 1, name: "敵2", hp: 120, max_hp: 120, atk: 30, info: "てんぷれ")
# ステージ2の敵（3体）
Enemyfreet.create(stage: 2, name: "敵3", hp: 150, max_hp: 150, atk: 40, info: "てんぷれ")
Enemyfreet.create(stage: 2, name: "敵4", hp: 150, max_hp: 150, atk: 40, info: "てんぷれ")
Enemyfreet.create(stage: 2, name: "敵5", hp: 200, max_hp: 200, atk: 50, info: "てんぷれ")
# ===========================
# 味方データ
# ===========================
Myfreet.create(name: "味方1", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと")
Myfreet.create(name: "味方2", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと")
Myfreet.create(name: "味方3", hp: 100, max_hp: 100, atk: 25, info: "てんぷれーと")
# ===========================
# ストーリーデータ
# ===========================
# 第0話
episode0 = [
  ["システム", "＜紫星・磯秋より、紫星・Userへ、メッセージを送信します。＞"],
  ["磯秋", "「あなたはもう、こちらに向かっているのでしょうか…」"],
  ["システム", "＜時間切れになりました。メッセージを終了します。＞"],
  ["System", "BattleStart", 1],
  ["？？？", "てすと"],
  ["System", "BattleStart", 2],
  ["？？？", "てすと"]
  # ここに続きの文章を追加していく
]

episode0.each_with_index do |(name, text, battle), i|
  Story.create(episode: 0, step: i+1, name: name, text: text, style: 0, battle: battle || 0)
end
# 第1話
episode1 = [
  ["ナレーション", "＜集結編第1話　未知の通信システム＞"],
  ["？？？", "てすと"],
  ["？？？", "てすと"],
  ["？？？", "てすと"]
]

episode1.each_with_index do |(name, text, battle), i|
  Story.create(episode: 1, step: i+1, name: name, text: text, style: 0, battle: battle || 0)
end
