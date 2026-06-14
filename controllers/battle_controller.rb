# 🌐 A: メインのバトル画面（布陣・演出・戦闘をすべてここで内蔵管理）
get '/battle' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user
  # 🧹 ✨【ここを追記】布陣画面に来た＝新しくやり直すので、戦闘状態を完全リセット！
  @phase = 'prepare'
  session[:battle_phase] = 'prepare' # セッション側も一応戻す
  session[:battle_allies] = nil      # 前回の味方の残りHPデータを消去
  session[:battle_enemies] = nil     # 前回の敵の残りHPデータを消去
  session[:battle_logs] = nil        # 前回の戦闘ログを消去
  # 📦 画面のどこであっても絶対に必要になる「共通の家具」を常に取得
  @stage = session[:battle_stage] || 1
  @fleets = @user.user_battleunits.order(:fleet_number)
  @enemy_fleets = EnemyBattleunit.where(battle_stage_id: @stage)

  # ⚡ 🟢 【ここを追記】準備フェーズ（演出モード）の判定

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

# 🔄 C: 戦闘フェーズ（ターン進行処理）
get '/battle/turn' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 🚨 🛑 【追加：安全装置】
  # セッションに味方や敵のデータがない（配置フェーズを踏んでいない）なら、強制的に布陣画面に送還する！
  if session[:battle_allies].nil? || session[:battle_enemies].nil?
    redirect '/battle'
  end

  # 📥 セッションから現在の両軍のリアルタイムデータを取得
  @allies = session[:battle_allies] || []
  @enemies = session[:battle_enemies] || []
  
  # 📝 今回のターンの行動ログを溜める配列
  @turn_logs = []
  # 📥 🟢 【ここを追記】戦闘開始時の両軍の健康状態をログに強制出力！
  @turn_logs << "ーーー 📊 現時刻・戦況報告 ーーー"
  if @allies.empty?
    @turn_logs << "⚠️ 警告：出撃している味方艦隊がいません！"
  else
    @allies.each do |a| 
      # 万が一HPが0で生成されていたら、デバッグ用に100にしてあげる救済処置
      if a[:hp] <= 0
        a[:hp] = 100
        a[:max_hp] = 100
        @turn_logs << "🔧 救済：#{a[:name]}のHPが0だったため応急修理(HP100)"
      end
      @turn_logs << "🚢 #{a[:name]}：HP #{a[:hp]}/#{a[:max_hp]} [位置: #{a[:col]},#{a[:row]}]"
    end
  end
  @enemies.each { |e| @turn_logs << "👾 #{e[:name]}：HP #{e[:hp]}/#{e[:max_hp]} [位置: #{e[:col]},#{e[:row]}]" }
  @turn_logs << "ーーーーーーーーーーーーーーーー"
  # 1️⃣ 【行動順の決定】
  # 味方と敵をすべて混ぜて、行動順のリスト（キュー）を作ります。
  # 今回はシンプルに「配置されている全員」を行動ループに回します。
  all_units = []
  @allies.each  { |a| all_units << { type: :ally,  data: a } }
  @enemies.each { |e| all_units << { type: :enemy, data: e } }

  # 2️⃣ 【移動 → 照準 → 攻撃 の行動ループ】
  all_units.each do |unit|
    current = unit[:data]
    next if current[:hp] <= 0 # すでに撃沈しているならパス

    if unit[:type] == :ally
      # ==========================================
      # 🚢 味方艦隊のターン
      # ==========================================
      
      # 🗺️ ①【移動】：とりあえず一番近い敵を探す（簡易版）
      # ここでは仮に、最初にみつかった生存している敵をターゲットにします
      target_enemy = @enemies.find { |e| e[:hp] > 0 }
      
      if target_enemy
        @turn_logs << "🤖 #{current[:name]}：行動開始。"
        
        # 🎯 ②【照準】＆ ③【攻撃】：敵を狙って攻撃力をぶつける！
        damage = current[:atk]
        target_enemy[:hp] -= damage
        target_enemy[:hp] = 0 if target_enemy[:hp] < 0 # マイナスHP防止
        
        @turn_logs << "⚔️ #{current[:name]} が #{target_enemy[:name]} に主砲一斉射！【#{damage}】のダメージ！"
        @turn_logs << "💥 #{target_enemy[:name]} の残りHP: #{target_enemy[:hp]}/#{target_enemy[:max_hp]}"
        
        if target_enemy[:hp] <= 0
          @turn_logs << "☠️ 撃沈！ #{target_enemy[:name]} は光の塵となって消滅した。"
        end
      end

    else
      # ==========================================
      # 👾 敵艦隊のターン
      # ==========================================
      target_ally = @allies.find { |a| a[:hp] > 0 }
      
      if target_ally
        damage = current[:atk]
        target_ally[:hp] -= damage
        target_ally[:hp] = 0 if target_ally[:hp] < 0
        
        @turn_logs << "🚨 敵警報！ #{current[:name]} の反撃！ #{target_ally[:name]} が被弾！【#{damage}】のダメージ！"
        @turn_logs << "❤️ #{target_ally[:name]} の残りHP: #{target_ally[:hp]}/#{target_ally[:max_hp]}"
      end
    end
  end

  # 💾 変動したHPなどの最新状態をセッションに上書き保存
  session[:battle_allies] = @allies
  session[:battle_enemies] = @enemies

  # 📊 🛡️ 【修正：勝敗判定の厳密化】
  # 「そもそもキャラクターが存在する(any?)」かつ「全員のHPが0(all?)」を条件にする（嘘の大成功対策）
  all_enemies_dead = @enemies.any? && @enemies.all? { |e| e[:hp] <= 0 }
  all_allies_dead  = @allies.any?  && @allies.all?  { |a| a[:hp] <= 0 }

  if all_enemies_dead
    @turn_logs << "🎉 作戦大成功！ 海域の敵艦隊をすべて駆逐しました！"
  elsif all_allies_dead
    @turn_logs << "🏳️ 作戦失敗… 総員、急速転舵。これ以上の作戦続行は不可能です！"
  end

  # 共通の家具を取得して、バトルのURLのまま戦闘結果ログを表示する
  @stage = session[:battle_stage] || 1
  @fleets = @user.user_battleunits.order(:fleet_number)
  @enemy_fleets = EnemyBattleunit.where(battle_stage_id: @stage)
  @phase = 'turn' # 画面側に「戦闘中だよ」と教えるスイッチ

  erb :battle
end