# ===========================
# 編成機能POST
# ===========================
post '/battle/set' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # ストーリーから送られてきたステージIDをセット（なければデフォルト1）
  stage = (params[:stage] || 1).to_i
  session[:battle_stage] = stage

  # 🔥 【ここで一発クリーンアップ】
  # 画面を開き直した瞬間なので、前回のログや味方データを完全に初期化する
  session[:battle_logs] = []
  session[:battle_allies] = nil

  # 👾 【敵データの初回ロード】
  # DB（EnemyBattleunit）から今回のステージの敵を呼び出し、HPを持たせた戦闘用セッションを作る
  enemy_units = EnemyBattleunit.where(battle_stage_id: stage)
  enemy_data_array = enemy_units.map do |unit|
    # 1. 旗艦のデータを「EnemyFreet」から探す
    enemy_freet_flag = EnemyFreet.find_by(id: unit.flagship_id)
    next nil unless enemy_freet_flag
    
    # 2. そのEnemyFreetが持っている「allfreet_id」を使って、ベースとなる能力（Allfreet）を引く
    flagship = Allfreet.find_by(id: enemy_freet_flag.allfreet_id)
    next nil unless flagship

    {
      id: unit.id, 
      name: "👾 #{flagship.name}", 
      col: unit.col, 
      row: unit.row, 
      flagship: { 
        id: unit.flagship_id, # EnemyFreetのID
        hp: flagship.hp,      # 今後は level を掛け算するロジックなどもここに入れられます！
        max_hp: flagship.hp 
      }, 
      sub_ships: (1..6).map { |i| 
        ship_id = unit.send("sub_ship_#{i}_id") # EnemyFreetのIDが入ってくる
        next nil if ship_id.blank? 

        # 随伴艦も同様に EnemyFreet -> Allfreet の順で探す
        ef_sub = EnemyFreet.find_by(id: ship_id)
        next nil unless ef_sub

        sub_ship = Allfreet.find_by(id: ef_sub.allfreet_id)
        
        sub_ship ? { id: ship_id, hp: sub_ship.hp, max_hp: sub_ship.hp } : nil 
      }.compact 
    }
  end.compact

  # 🎁 作成したデータを、リダイレクトしても消えないセッションに大切に保管する！
  session[:battle_enemies] = enemy_data_array
  puts "====== 敵データロードテスト ======"
  puts "セッションに入れた敵データ: #{session[:battle_enemies].inspect}"
  # 初期化がすべて安全に完了したので、描画担当のGETへリダイレクト！
  redirect '/battle/set'
end
# ===========================
# 編成機能GET
# ===========================
get '/battle/set' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 📦 画面に必要な家具を、リロードに強いセッションから安全に復元するだけ！
  @stage = session[:battle_stage] || 1
  
  # 古い味方配置を一旦クリアする
  session[:battle_allies] = nil if params[:phase].blank? && !session[:battle_enemies].blank?

  @fleets = @user.user_battleunits.order(:fleet_number)
  
  # 🔍 もしストーリーから直接GETへ飛んできて敵データがまだ無ければ、ここで正しくロードする
  if session[:battle_enemies].blank?
    enemy_units = EnemyBattleunit.where(battle_stage_id: @stage)
    session[:battle_enemies] = enemy_units.map do |unit|
      enemy_freet_flag = EnemyFreet.find_by(id: unit.flagship_id)
      next nil unless enemy_freet_flag
      flagship = Allfreet.find_by(id: enemy_freet_flag.allfreet_id)
      next nil unless flagship
      
      {
        id: unit.id, 
        name: "👾 #{flagship.name}", 
        col: unit.col, 
        row: unit.row, 
        flagship: { id: unit.flagship_id, hp: flagship.hp, max_hp: flagship.hp }, 
        sub_ships: (1..6).map { |i| 
          ship_id = unit.send("sub_ship_#{i}_id")
          next nil if ship_id.blank? 
          ef_sub = EnemyFreet.find_by(id: ship_id)
          next nil unless ef_sub
          sub_ship = Allfreet.find_by(id: ef_sub.allfreet_id)
          sub_ship ? { id: ship_id, hp: sub_ship.hp, max_hp: sub_ship.hp } : nil 
        }.compact 
      }
    end.compact
  end

  # POSTで生成された「本物の敵データ」がここに入る（リロードしても絶対に消えない）
  @enemies = session[:battle_enemies] || [] # 👈 後ろに「|| []」を追記
  @allies = session[:battle_allies]   # 布陣前は nil、出撃後はデータが入る

  # パラメータによるフェーズ管理は廃止。実データ（@allies）があるかどうかで準備状態を自動判定
  if @allies
    @prep_logs = ["両軍、布陣完了。これより戦闘フェーズに移行します！"]
  end

  erb :battle
end

post '/battle/start' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  battle_allies = []

  (1..6).each do |fleet_num|
    pos_str = params["fleet_#{fleet_num}_pos"]
    next if pos_str.blank?

    col, row = pos_str.split(',').map(&:to_i)
    fleet_data = @user.user_battleunits.find_by(fleet_number: fleet_num)
    next unless fleet_data

    # 👑 旗艦データをDBから正しくロード
    flagship = UserMyfreet.find_by(id: fleet_data.flagship_id)
    next unless flagship # 旗艦がいなければスキップ

    base_flag_hp = flagship.allfreet.hp
    base_flag_hp *= 10 if fleet_num == 1 # 第一艦隊旗艦10倍ルール

    flagship_data = { id: fleet_data.flagship_id, hp: base_flag_hp, max_hp: base_flag_hp }

    # ⚓ 随伴艦データ（1〜6）をDBから正しくロード
    sub_ships_data = []
    (1..6).each do |i|
      ship_id = fleet_data.send("sub_ship_#{i}_id")
      next if ship_id.blank?

      sub_ship = UserMyfreet.find_by(id: ship_id)
      if sub_ship
        sub_ships_data << { id: ship_id, hp: sub_ship.allfreet.hp, max_hp: sub_ship.allfreet.hp }
      end
    end

    battle_allies << {
      fleet_number: fleet_num,
      name: "第#{fleet_num}艦隊",
      col: col,
      row: row,
      flagship: flagship_data,
      sub_ships: sub_ships_data
    }
  end

  session[:battle_allies] = battle_allies

  # 👾 敵のデータ構築（enemy_battleunits -> enemy_freets -> allfreets）
  stage = (params[:stage] || 1).to_i
  if session[:battle_enemies].blank?
    enemy_units = EnemyBattleunit.where(battle_stage_id: stage)
    session[:battle_enemies] = enemy_units.map do |unit|
      enemy_freet_flag = EnemyFreet.find_by(id: unit.flagship_id)
      next nil unless enemy_freet_flag
    
      flagship = Allfreet.find_by(id: enemy_freet_flag.allfreet_id)
      next nil unless flagship

      {
        id: unit.id, 
        name: "👾 #{flagship.name}", 
        col: unit.col, 
        row: unit.row, 
        flagship: { id: unit.flagship_id, hp: flagship.hp, max_hp: flagship.hp }, 
        sub_ships: (1..6).map { |i| 
          ship_id = unit.send("sub_ship_#{i}_id")
          next nil if ship_id.blank? 
          ef_sub = EnemyFreet.find_by(id: ship_id)
          next nil unless ef_sub
          sub_ship = Allfreet.find_by(id: ef_sub.allfreet_id)
          sub_ship ? { id: ship_id, hp: sub_ship.hp, max_hp: sub_ship.hp } : nil 
        }.compact 
      }
    end.compact
  end

  session[:battle_logs] = []
  redirect '/battle/turn' #  /battle/turn へ
end



#バトル画面で自分のキャラと相手のキャラを選択して攻撃を実行する際に行う処理
post '/battle/attack' do
  # 攻撃と被攻撃のユニットをセッションから取得
  @my_units = session[:my_freets]
  @enemy_units = session[:enemy_freets]

  # 攻撃ユニットと被攻撃ユニットを特定
  attacker = @my_units.find { |unit| unit['myfreet']["id"] == params[:my_unit_id].to_i }
  defender = @enemy_units.find { |unit| unit["id"] == params[:enemy_unit_id].to_i }

  # 攻撃処理
  defender["hp"] -= attacker['myfreet']["atk"]
  defender["hp"] = [defender["hp"], 0].max # HPが0未満にならないよう制御

  # 更新されたデータをセッションに保存
  session[:my_freets] = @my_units
  session[:enemy_freets] = @enemy_units
  session[:last_attack] = {
    attacker: attacker['myfreet']["id"],
    defender: defender["id"],
    damage: attacker['myfreet']["atk"]
  }
  # バトル画面へリダイレクト
  redirect '/battle'
end

# 🔄 C: 戦闘フェーズ（ターン進行処理）
get '/battle/turn' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  if session[:battle_allies].blank? || session[:battle_enemies].blank?
    redirect '/battle/set'
  end

  @allies = session[:battle_allies]
  @enemies = session[:battle_enemies]
  @turn_logs = []

  # 行動順リストの作成
  all_units = []
  @allies.each  { |a| all_units << { type: :ally,  data: a } }
  @enemies.each { |e| all_units << { type: :enemy, data: e } }

  all_units.each do |unit|
    current = unit[:data]
    
    # 艦隊の総HPを計算（旗艦 + 随伴艦の合計）
    current_total_hp = current[:flagship][:hp] + current[:sub_ships].sum { |s| s[:hp] }
    next if current_total_hp <= 0

    if unit[:type] == :ally
      # 🎯 攻撃対象（生存している敵）の選定
      target_enemy = @enemies.find { |e| (e[:flagship][:hp] + e[:sub_ships].sum { |s| s[:hp] }) > 0 }
      if target_enemy
        # 味方艦隊の全生存艦の攻撃力を、DBのマスタから動的に合計する
        total_atk = 0
        
        if current[:flagship][:hp] > 0
          flag_obj = UserMyfreet.find_by(id: current[:flagship][:id])
          flag_atk = flag_obj&.allfreet&.atk || 0
          flag_atk *= 10 if current[:fleet_number] == 1 # 10倍ルール
          total_atk += flag_atk
        end
        
        current[:sub_ships].each do |s|
          if s[:hp] > 0
            sub_obj = UserMyfreet.find_by(id: s[:id])
            total_atk += (sub_obj&.allfreet&.atk || 0)
          end
        end
        total_atk = 10 if total_atk <= 0 # 最低保証

        # 敵の生存艦プールからランダムに1隻被弾
        pool = []
        pool << target_enemy[:flagship] if target_enemy[:flagship][:hp] > 0
        target_enemy[:sub_ships].each { |s| pool << s if s[:hp] > 0 }

        if pool.any?
          target_ship = pool.sample
          target_ship[:hp] -= total_atk
          target_ship[:hp] = 0 if target_ship[:hp] < 0

          # 被弾した敵の船の名前をDBから直接引く
          enemy_ship_obj = EnemyFreet.find_by(id: target_ship[:id])
          enemy_ship_name = enemy_ship_obj&.allfreet&.name || "敵艦"

          @turn_logs << "⚔️ #{current[:name]} が砲撃！ 敵の『#{enemy_ship_name}』に【#{total_atk}】ダメージ！"
        end
      end
    else
      # 👾 敵の反撃ロジック（同様にDBから攻撃力を集計して味方を狙う）
      target_ally = @allies.find { |a| (a[:flagship][:hp] + a[:sub_ships].sum { |s| s[:hp] }) > 0 }
      if target_ally
        total_atk = 0
        if current[:flagship][:hp] > 0
          flag_obj = EnemyFreet.find_by(id: current[:flagship][:id])
          total_atk += flag_obj&.allfreet&.atk || 0
        end
        current[:sub_ships].each do |s|
          if s[:hp] > 0
            sub_obj = EnemyFreet.find_by(id: s[:id])
            total_atk += (sub_obj&.allfreet&.atk || 0)
          end
        end
        total_atk = 10 if total_atk <= 0

        pool = []
        pool << target_ally[:flagship] if target_ally[:flagship][:hp] > 0
        target_ally[:sub_ships].each { |s| pool << s if s[:hp] > 0 }

        if pool.any?
          target_ship = pool.sample
          target_ship[:hp] -= total_atk
          target_ship[:hp] = 0 if target_ship[:hp] < 0

          ally_ship_obj = UserMyfreet.find_by(id: target_ship[:id])
          ally_ship_name = ally_ship_obj&.allfreet&.name || "味方艦"

          @turn_logs << "🚨 #{current[:name]} の反撃！ 『#{ally_ship_name}』が被弾！【#{total_atk}】ダメージ！"
        end
      end
    end
  end

  session[:battle_allies] = @allies
  session[:battle_enemies] = @enemies

  # 勝敗判定（全船のHP合計が0か）
  all_enemies_dead = @enemies.all? { |e| e[:flagship][:hp] + e[:sub_ships].sum { |s| s[:hp] } <= 0 }
  all_allies_dead  = @allies.all?  { |a| a[:flagship][:hp] + a[:sub_ships].sum { |s| s[:hp] } <= 0 }

  if all_enemies_dead
    @turn_logs << "🎉 作戦大成功！ 海域の敵艦隊をすべて駆逐しました！"
    session[:battle_result] = "win"         # 👈 勝利フラグをセッションに保存
    return redirect '/battle/result'        # 👈 結果画面へ即座に遷移！
  elsif all_allies_dead
    @turn_logs << "🏳️ 作戦失敗… 総員、急速転舵！"
    session[:battle_result] = "lose"        # 👈 敗北フラグをセッションに保存
    return redirect '/battle/result'        # 👈 結果画面へ即座に遷移！
  end

  @stage = session[:battle_stage] || 1
  @fleets = @user.user_battleunits.order(:fleet_number)
  @enemy_fleets = EnemyBattleunit.where(battle_stage_id: @stage)
  @phase = 'turn'

  erb :battle
end

# 🏁 【新設】戦闘結果画面を表示する処理
get '/battle/result' do
  # 1. 画面が求めている「@finaresult」に、日本語の「勝利」か「敗北」をセット
  @finaresult = (session[:battle_result] == "win") ? "勝利" : "敗北"
  
  # 2. 画面の19行目がエラーにならないよう、セッションにある味方データを渡す
  raw_units = session[:battle_allies] || [] # 👈 ここを「user_freets」に変更します
  @my_units = raw_units.map do |u|
    {
      'level' => u['level'],
      'exp'   => u['exp'],
      'myfreet' => {
        'id'     => u['id'],
        'name'   => u['allfreet'] ? u['allfreet']['name'] : "味方艦",
        'hp'     => u['allfreet'] ? u['allfreet']['hp'] : 100,
        'max_hp' => u['allfreet'] ? u['allfreet']['max_hp'] : 100,
        'atk'    => u['allfreet'] ? u['allfreet']['atk'] : 25,
        'info'   => u['allfreet'] ? u['allfreet']['info'] : ""
      }
    }
  end
  
  erb :result
end