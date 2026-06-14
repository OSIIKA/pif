# 🌐 A: メインのバトル画面（布陣・演出・戦闘をすべてここで内蔵管理）
get '/battle' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 📦 画面のどこであっても絶対に必要になる「共通の家具」を常に取得
  @stage = session[:battle_stage] || 1
  @fleets = @user.user_battleunits.order(:fleet_number)
  @enemy_fleets = EnemyBattleunit.where(battle_stage_id: @stage)

  # ⚡ 🟢 【ここを追記】準備フェーズ（演出モード）の判定
  @phase = params[:phase] # URLの「?phase=prepare」を読み取る

  if @phase == 'prepare'
    @allies = session[:battle_allies]
    @prep_logs = []
    
    # セッションから戦技ログを組み立てる
    @allies&.each do |fleet|
      if fleet[:skills]&.any?
        fleet[:skills].each { |s| @prep_logs << "【味方】#{fleet[:name]} - #{s}" }
      end
    end
    @prep_logs << "両軍、布陣完了。これより戦闘フェーズに移行します！" if @prep_logs.empty?
  end

  erb :battle
end

# ⚔️ B: 布陣確定後のデータ処理
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

    total_hp = 0
    total_atk = 0
    skill_logs = []

    flagship = UserMyfreet.find_by(id: fleet_data.flagship_id)
    sub_1    = UserMyfreet.find_by(id: fleet_data.sub_ship_1_id)
    sub_2    = UserMyfreet.find_by(id: fleet_data.sub_ship_2_id)
    sub_3    = UserMyfreet.find_by(id: fleet_data.sub_ship_3_id)
    sub_4    = UserMyfreet.find_by(id: fleet_data.sub_ship_4_id)
    sub_5    = UserMyfreet.find_by(id: fleet_data.sub_ship_5_id)
    sub_6    = UserMyfreet.find_by(id: fleet_data.sub_ship_6_id)

    ships = [{ ship: flagship, is_flag: true }, sub_1, sub_2, sub_3, sub_4, sub_5, sub_6].compact

    ships.each do |item|
      ship = item.is_a?(Hash) ? item[:ship] : item
      next unless ship

      base_hp = ship.allfreet.hp
      base_atk = ship.allfreet.atk

      if fleet_num == 1 && item.is_a?(Hash) && item[:is_flag]
        base_hp *= 10
        base_atk *= 10
        skill_logs << "第一艦隊旗艦戦技：【臨界突破・十倍界王拳】発動！"
      end

      total_hp += base_hp
      total_atk += base_atk
    end

    battle_allies << {
      fleet_number: fleet_num,
      name: "第#{fleet_num}艦隊",
      max_hp: total_hp,
      hp: total_hp,
      atk: total_atk,
      col: col,
      row: row,
      skills: skill_logs
    }
  end

  session[:battle_allies] = battle_allies

  stage = (params[:stage] || 1).to_i
  enemy_units = EnemyBattleunit.where(battle_stage_id: stage)
  
  session[:battle_enemies] = enemy_units.map do |unit|
    enemy_hp = unit.flagship.allfreet.hp
    enemy_atk = unit.flagship.allfreet.atk
    {
      id: unit.id,
      name: "👾 #{unit.flagship.allfreet.name}",
      max_hp: enemy_hp,
      hp: enemy_hp,
      atk: enemy_atk,
      col: unit.col,
      row: unit.row
    }
  end

  session[:battle_logs] = []

  # ❌ 修正前: redirect '/battle/prepare'
  # ⭕ 修正後: 別ページにいかず、元の画面に「演出モードの鍵」を持たせて戻る！
  redirect '/battle?phase=prepare'
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