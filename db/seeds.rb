# 📄 db/seeds.rb の1行目に追記
require_relative '../app'
# ===========================
# 📚ユーザー（システム）データ
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
# 📚スキル辞書
# ===========================
Skill.find_or_create_by!(id: 1, name: "攻撃力上昇", effect_type: "atk_up") do |s|
  s.value = 10
  s.description = "攻撃力が10上昇する基本スキル。"
end
Skill.find_or_create_by!(id: 2, name: "攻撃力強化・改", effect_type: "atk_up") do |s|
  s.value = 20
  s.description = "攻撃力が20上昇する強化版スキル。"
end
Skill.find_or_create_by!(id: 3, name: "攻撃力強化・零式", effect_type: "atk_up") do |s|
  s.value = 30
  s.description = "紫鉄艦隊の象徴的スキル。攻撃力が30上昇する。"
end
Skill.find_or_create_by!(id: 4, name: "速度上昇", effect_type: "speed_up") do |s|
  s.value = 5
  s.description = "速度が5上昇する。機動力が向上する。"
end
Skill.find_or_create_by!(id: 5, name: "AI戦術補助", effect_type: "special") do |s|
  s.value = 1
  s.description = "Mk.628系ユニットが持つ特殊スキル。戦術補助を行う。"
end
# ===========================
# 📚敵・味方辞書
# ===========================
ships = [
  # ===========================
  # 📕味方データ
  # ===========================
  {
    stage: 1,
    name: "紫鉄（試作型）",
    hp: 1200, max_hp: 1200, atk: 150, speed: 30,
    info: "紫鉄艦隊の基礎となる試作艦。",
    image_url: "/images/ships/shitetu_01.png",
    object_url: "/objects/shitetu_01.glb",
    skill_id: 1,
    rarity: 1,
    normal: 5, rare: 0, limited: 0, story: 1, event: 0
  },
  {
    stage: 2,
    name: "紫鉄・改",
    hp: 1800, max_hp: 1800, atk: 220, speed: 35,
    info: "試作型を改修した量産モデル。",
    image_url: "/images/ships/shitetu_02.png",
    object_url: "/objects/shitetu_02.glb",
    skill_id: 2,
    rarity: 2,
    normal: 0, rare: 3, limited: 0, story: 0, event: 1
  },
  {
    stage: 3,
    name: "紫鉄・零式",
    hp: 2500, max_hp: 2500, atk: 300, speed: 40,
    info: "紫鉄艦隊の象徴となる高性能艦。",
    image_url: "/images/ships/shitetu_03.png",
    object_url: "/objects/shitetu_03.glb",
    skill_id: 3,
    rarity: 3,
    normal: 0, rare: 0, limited: 1, story: 0, event: 0
  },
  # ===========================
  # 📕敵データ
  # ===========================
  {
    stage: 1,
    name: "敵1",
    hp: 100, max_hp: 100, atk: 25, speed: 10,
    info: "てんぷれ",
    image_url: "/images/ships/enemy_01.png",
    object_url: "/objects/enemy_01.glb",
    skill_id: 1,
    rarity: 1,
    normal: 100, rare: 100, limited: 0, story: 1, event: 0
  },
  {
    stage: 1,
    name: "敵2",
    hp: 100, max_hp: 100, atk: 25, speed: 10,
    info: "てんぷれ",
    image_url: "/images/ships/enemy_02.png",
    object_url: "/objects/enemy_02.glb",
    skill_id: 1,
    rarity: 1,
    normal: 100, rare: 100, limited: 0, story: 1, event: 0
  },
  {
    stage: 2,
    name: "敵3",
    hp: 100, max_hp: 100, atk: 25, speed: 10,
    info: "てんぷれ",
    image_url: "/images/ships/enemy_03.png",
    object_url: "/objects/enemy_03.glb",
    skill_id: 1,
    rarity: 1,
    normal: 100, rare: 100, limited: 0, story: 1, event: 0
  },
  {
    stage: 2,
    name: "敵4",
    hp: 100, max_hp: 100, atk: 25, speed: 10,
    info: "てんぷれ",
    image_url: "/images/ships/enemy_04.png",
    object_url: "/objects/enemy_04.glb",
    skill_id: 1,
    rarity: 1,
    normal: 100, rare: 100, limited: 0, story: 1, event: 0
  },
  {
    stage: 2,
    name: "敵5",
    hp: 100, max_hp: 100, atk: 25, speed: 10,
    info: "てんぷれ",
    image_url: "/images/ships/enemy_05.png",
    object_url: "/objects/enemy_05.glb",
    skill_id: 1,
    rarity: 1,
    normal: 100, rare: 100, limited: 0, story: 1, event: 0
  }
]
ships.each do |ship|
  Allfreet.find_or_create_by!(ship)
end
# ===========================
# 📚アイテム辞書
# ===========================
Item.find_or_create_by!(id: 1, name: "紫鉄", category: 1, rarity: 1) do |item|
  item.description = "ガチャを引くための基本アイテム。"
end
Item.find_or_create_by!(id: 2, name: "レアガチャチケット", category: 2, rarity: 2) do |item|
  item.description = "レアガチャを1回引くことができるチケット。"
end
Item.find_or_create_by!(id: 3, name: "期間限定ガチャチケット", category: 2, rarity: 2) do |item|
  item.description = "期間限定のレアガチャを1回引くことができるチケット。"
end
Item.find_or_create_by!(id: 4, name: "レアガチャシール", category: 2, rarity: 2) do |item|
  item.description = "レア作戦のガチャシール。一定数で限定艦船と交換可能。"
end
Item.find_or_create_by!(id: 5, name: "期間限定ガチャシール", category: 2, rarity: 2) do |item|
  item.description = "期間限定作戦のガチャシール。一定数で限定艦船と交換可能。"
end
# ===========================
# 📚キャラクター辞書
# ===========================
Character.find_or_create_by!(id: 1, name: "北上湊", affiliation: 1, rarity: 1, skill_id: 1) do |c|
  c.bio = "紫鉄艦隊を率いる若き司令官。冷静沈着で判断力に優れる。"
end
Character.find_or_create_by!(id: 2, name: "磯秋", affiliation: 1, rarity: 1, skill_id: 1) do |c|
  c.bio = "磯秋の経歴・プロフィール。"
end
Character.find_or_create_by!(id: 3, name: "Mk.628", affiliation: 1, rarity: 1, skill_id: 1) do |c|
  c.bio = "Mk.628の経歴・プロフィール。"
end
Character.find_or_create_by!(id: 4, name: "Mk.628-2", affiliation: 1, rarity: 1, skill_id: 1) do |c|
  c.bio = "Mk.628-2の経歴・プロフィール。"
end
# ===========================
# 📚武器辞書
# ===========================
Weapon.find_or_create_by!(id: 1, name: "紫鉄砲", rarity: 1, skill_id: 1) do |w|
  w.info = "紫鉄艦隊の標準装備。扱いやすく汎用性が高い。"
end
Weapon.find_or_create_by!(id: 2, name: "紫鉄砲・改", rarity: 2, skill_id: 2) do |w|
  w.info = "試作型を改修した強化版。攻撃力が向上している。"
end
Weapon.find_or_create_by!(id: 3, name: "紫鉄砲・零式", rarity: 3, skill_id: 3) do |w|
  w.info = "紫鉄艦隊の象徴となる高性能武器。限定ガチャでのみ入手可能。"
end
Weapon.find_or_create_by!(id: 4, name: "Mk.628支援砲", rarity: 2, skill_id: 4) do |w|
  w.info = "Mk.628が使用する支援砲。命中精度が高く、補助効果を持つ。"
end
Weapon.find_or_create_by!(id: 5, name: "Mk.628-2高速砲", rarity: 3, skill_id: 5) do |w|
  w.info = "Mk.628-2専用の高速射撃武器。連射性能が大幅に向上している。"
end
# ===========================
# 📚アイテム配布データ
# ===========================
Itemtimeline.find_or_create_by!(step: 1, item_type: 0, item_each_id: 1, count: 100) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 2, item_type: 1, item_each_id: 1, count: 100) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 3, item_type: 1, item_each_id: 2, count: 100) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 4, item_type: 2, item_each_id: 1, count: 100) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 5, item_type: 2, item_each_id: 2, count: 100) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 6, item_type: 4, item_each_id: 1, count: 1) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 7, item_type: 4, item_each_id: 2, count: 1) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 8, item_type: 4, item_each_id: 3, count: 1) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end
Itemtimeline.find_or_create_by!(step: 9, item_type: 4, item_each_id: 4, count: 1) do |timeline|
  timeline.big_type = 1 # 大分類（例: ガチャ関連アイテム）
  timeline.small_type = 1 # 小分類（例: ログインボーナス）
end


# ===========================
# ===========================
# 敵データ
# ===========================
puts "🌱 敵データのシードを開始します..."
# ⚠️ 注意: データベースを何度もクリーンに叩き直したい場合は、
# データの重複を防ぐために最初に削除処理を入れておくと開発がラクになります。
EnemyBattleunit.destroy_all
EnemyFreet.destroy_all
# 1. 敵個体の作成 (EnemyFreet)
# ステージ番号_第何艦隊_個体番号 という命名ルールで変数を作ると、後から見たときにどの敵がどこに出てくるのかが一目瞭然になります！
enemy_zako_1_1_1 = EnemyFreet.create!(allfreet_id: 1, level: 3)
enemy_zako_1_1_2 = EnemyFreet.create!(allfreet_id: 1, level: 4)
enemy_boss_1_1 = EnemyFreet.create!(allfreet_id: 2, level: 8)
enemy_zako_2_1_1 = EnemyFreet.create!(allfreet_id: 3, level: 3)
enemy_zako_2_1_2 = EnemyFreet.create!(allfreet_id: 3, level: 4)
enemy_zako_2_1_3 = EnemyFreet.create!(allfreet_id: 3, level: 4)
enemy_boss_2_1 = EnemyFreet.create!(allfreet_id: 5, level: 8)
enemy_zako_2_2_1 = EnemyFreet.create!(allfreet_id: 4, level: 3)
enemy_zako_2_2_2 = EnemyFreet.create!(allfreet_id: 4, level: 4)
enemy_zako_2_2_3 = EnemyFreet.create!(allfreet_id: 4, level: 4)
enemy_boss_2_2 = EnemyFreet.create!(allfreet_id: 5, level: 8)
# 2. 敵艦隊（塊）の配置 (EnemyBattleunit)
# ストーリーの `battle: 1` と連動させるため、`battle_stage_id: 1` にします。
# 敵はマップの右側（col: 4〜5 付近）に湧かせると、左側から出撃する味方と対峙できて一気にゲームらしくなります！

EnemyBattleunit.create!(
  battle_stage_id: 1,
  col: 5,  # 右端の列
  row: 2,  # 中央の行
  sub_ship_1_id: enemy_zako_1_1_1.id, # 随伴1
  sub_ship_2_id: enemy_zako_1_1_2.id,  # 随伴2
  flagship_id:   enemy_boss_1_1.id # 旗艦
  # 随伴3〜6は指定しない（nilになる）ことで、3隻編成の艦隊になります！
)

EnemyBattleunit.create!(
  battle_stage_id: 2,
  col: 4,
  row: 1,
  sub_ship_1_id: enemy_zako_2_1_1.id,
  sub_ship_2_id: enemy_zako_2_1_2.id,
  sub_ship_3_id: enemy_zako_2_1_3.id,
  flagship_id:   enemy_boss_2_1.id
)
EnemyBattleunit.create!(
  battle_stage_id: 2,
  col: 4,
  row: 2,
  sub_ship_1_id: enemy_zako_2_2_1.id,
  sub_ship_2_id: enemy_zako_2_2_2.id,
  sub_ship_3_id: enemy_zako_2_2_3.id,
  flagship_id:   enemy_boss_2_2.id
)

puts "✨ 敵データのシードが完了しました！（EnemyFreet / EnemyBattleunit 登録完了）"
# ===========================
# ストーリーデータ
# ===========================
# 既存データを一度お掃除
Story.delete_all

# ===========================================================
# 📖 ここにストーリーの台本をそのまま貼り付けるだけ！
# ===========================================================
# 【書き方ルール】
# ・「●話数」で行を始めると、そこからそのエピソードになります。
# ・「名前: セリフ」の形式で書きます（コロンは全角でも半角でもOK）。
# ・「[BATTLE: ステージ番号]」と書くと、そのタイミングで戦闘を挟めます。
# ===========================================================
script = <<~TEXT
  ●0
  システム: ＜紫星・磯秋より、紫星・Userへ、メッセージを送信します。＞
  磯秋: 「あなたはもう、こちらに向かっているのでしょうか…」
  システム: ＜時間切れになりました。メッセージを終了します。＞
  [BATTLE: 1]
  ？？？: てすと
  [BATTLE: 2]
  ？？？: てすと

  ●1
  ナレーション: ＜集結編第1話 未知の通信システム＞
  ？？？: てすと
  ？？？: てすと
  ？？？: てすと
  [BATTLE: 3]
TEXT


# ===========================================================
# ⚙️ 台本テキストを自動で解析（パース）してDBに保存するロジック
# ===========================================================
current_episode = 0
current_step = 1

script.each_line do |line|
  line = line.strip
  next if line.empty? # 空行はスキップ

  # 1. 「●話数」の行を見つけたらエピソードを切り替えてステップをリセット
  if line.start_with?("●")
    current_episode = line.delete("●").to_i
    current_step = 1
    next
  end

  # 2. 「[BATTLE: 番号]」の行を見つけたら、直前の会話にバトルを設定するか、戦闘用ステップを作る
  if line =~ /\[BATTLE:\s*(\d+)\]/
    battle_num = $1.to_i
    
    # 特殊な戦闘イベント用レコードとして登録
    Story.create!(
      episode: current_episode,
      step: current_step,
      name: "System",
      text: "BattleStart",
      battle: battle_num
    )
    current_step += 1
    next
  end

  # 3. 通常の「名前: セリフ」を分割して登録（全角コロン・半角コロン両対応）
  if line =~ /(.+?)[:：](.+)/
    name = $1.strip
    text = $2.strip

    Story.create!(
      episode: current_episode,
      step: current_step,
      name: name,
      text: text,
      battle: 0
    )
    current_step += 1
  end
end

puts "🌱 台本からのストーリーデータのインポートが完了しました！"
# ==========================================
# 🚨 PostgreSQLの自動採番カウンター（シーケンス）を現在の最大IDに同期する
# ==========================================
if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
  # usersテーブルのカウンターを、現在の最大ID（1）の次（2）に強制進業する
  ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1))")
  # 他のテーブルも同様に必要に応じてシーケンスをリセットする
  ActiveRecord::Base.connection.execute("SELECT setval('myfreets_id_seq', COALESCE((SELECT MAX(id) FROM myfreets), 1))")
  ActiveRecord::Base.connection.execute("SELECT setval('allfreets_id_seq', COALESCE((SELECT MAX(id) FROM allfreets), 1))")
  ActiveRecord::Base.connection.execute("SELECT setval('stories_id_seq', COALESCE((SELECT MAX(id) FROM stories), 1))")
  ActiveRecord::Base.connection.execute("SELECT setval('skills_id_seq', COALESCE((SELECT MAX(id) FROM skills), 1))")
end