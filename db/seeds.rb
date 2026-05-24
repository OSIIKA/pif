# ===========================
# 敵データ
# ===========================
Enemyfreet.create(name: "敵1", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Enemyfreet.create(name: "敵2", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Enemyfreet.create(name: "敵3", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Enemyfreet.create(name: "敵4", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Enemyfreet.create(name: "敵5", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Enemyfreet.create(name: "敵6", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
# ===========================
# 味方データ
# ===========================
Myfreet.create(name: "味方1", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Myfreet.create(name: "味方2", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
Myfreet.create(name: "味方3", hp: "100", max_hp: "100", atk: "25", info: "てんぷれーと")
# ===========================
# ストーリーデータ
# ===========================
# 第0話
episode0 = [
  ["システム", "＜紫星・磯秋より、紫星・Userへ、メッセージを送信します。＞"],
  ["磯秋", "「あなたはもう、こちらに向かっているのでしょうか…」"],
  ["システム", "＜時間切れになりました。メッセージを終了します。＞"],
  ...
]

episode0.each_with_index do |(name, text), i|
  Story.create(episode: 0, step: i+1, name: name, text: text, style: 0)
end
# 第1話
episode1 = [
  ["ナレーション", "＜集結編第1話　未知の通信システム＞"],
  ["？？？", "てすと"],
  ["？？？", "てすと"],
  ["？？？", "てすと"]
]

episode1.each_with_index do |(name, text), i|
  Story.create(episode: 1, step: i+1, name: name, text: text, style: 0)
end
