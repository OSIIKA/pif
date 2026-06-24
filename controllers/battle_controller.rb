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
  session[:battle_allies_config] = nil if params[:phase].blank?

  @fleets = @user.user_battleunits.order(:fleet_number)
  
  if session[:battle_stage].blank?
    session[:battle_stage] = @stage
  end

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

  @enemies = session[:battle_enemies] || []

  # 配置が完了したかどうかを判定
  @battle_allies_deployed = session[:battle_allies_config].present?
  @battle_allies_positions = (session[:battle_allies_config] || []).map do |a|
    fleet_data = @fleets.find_by(fleet_number: a[:fleet_number])
    flagship = fleet_data && UserMyfreet.find_by(id: fleet_data.flagship_id)
    flagship_hp = flagship&.allfreet&.hp.to_i
    sub_hp_total = (1..6).sum do |i|
      ship_id = fleet_data&.send("sub_ship_#{i}_id")
      sub = ship_id.present? && UserMyfreet.find_by(id: ship_id)
      sub ? sub.allfreet.hp : 0
    end
    {
      col: a[:col].to_i,
      row: a[:row].to_i,
      fleet_number: a[:fleet_number],
      hp: flagship_hp + sub_hp_total,
      max_hp: flagship_hp + sub_hp_total
    }
  end

  # 失敗時のエラーメッセージを画面に渡す
  @battle_error = session.delete(:battle_error)

  # 配置完了後のログを表示
  if @battle_allies_deployed
    @prep_logs = ["両軍、布陣完了。これより戦闘フェーズに移行します！"]
  end

  erb :battle
  # ⚡【デバッグ：編成フェーズ表示不具合の調査】
  puts "====== 🔮 編成フェーズGETデータチェック ======"
  puts "現在の request.path_info: #{request.path_info}"
  @user = User.find_by(id: session[:user])
  puts "ログインユーザー: #{@user&.name} (ID: #{@user&.id})"
  if @user
    test_fleets = @user.user_battleunits.order(:fleet_number)
    puts "取得できた艦隊（user_battleunits）の数: #{test_fleets.count}"
    test_fleets.each do |f|
      puts "  - 第#{f.fleet_number}艦隊: 旗艦ID=#{f.flagship_id.inspect}"
    end
  end
  puts "==============================================="
end

post '/battle/start' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 🔍 【デバッグ】受け取ったすべてのパラメータをログ出力
  puts "====== /battle/start へのPOSTリクエスト ======"
  puts "受け取ったパラメータ:"
  (1..6).each do |fleet_num|
    value = params["fleet_#{fleet_num}_pos"]
    puts "  fleet_#{fleet_num}_pos: '#{value}' (blank? = #{value.blank?})"
  end
  puts "========================================="

  battle_allies = []

  (1..6).each do |fleet_num|
    pos_str = params["fleet_#{fleet_num}_pos"]
    next if pos_str.blank?

    # 🔍 【デバッグ】座標の解析を確認
    col, row = pos_str.split(',').map(&:to_i)
    puts "Fleet #{fleet_num}: col=#{col}, row=#{row}"

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

  # 🔍 【デバッグ】battle_allies の最終結果をログ出力
  puts "作成された battle_allies の数: #{battle_allies.length}"
  battle_allies.each do |ally|
    puts "  - Fleet #{ally[:fleet_number]}: col=#{ally[:col]}, row=#{ally[:row]}"
  end

  if battle_allies.empty?
    session[:battle_error] = "少なくとも1つの艦隊を配置してから出撃してください。"
    redirect '/battle/set'
  end

  # 💾 セッションサイズ削減：最小限のデータだけを保存
  # fleet_number, col, row だけをセッションに保存し、詳細データは /battle/turn で再構築
  session[:battle_allies_config] = battle_allies.map { |a| 
    { fleet_number: a[:fleet_number], col: a[:col], row: a[:row] }
  }

  # 👾 敵のデータ構築（enemy_battleunits -> enemy_freets -> allfreets）
  # 敵データは既に get '/battle/set' で session に入っているはず
  # ここでは敵の詳細データ（大量メモリ）をセッションから削除し、
  # 必要な時に /battle/turn で再構築するようにする
  stage = (params[:stage] || 1).to_i
  session[:battle_stage] = stage

  session[:battle_logs] = []
  session[:battle_phase] = 'prepare'
  redirect '/battle/prepare' # まず哨戒戦技フェーズへ
end

get '/battle/prepare' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  @stage = session[:battle_stage] || 1
  @fleets = @user.user_battleunits.order(:fleet_number)
  @enemies = session[:battle_enemies] || []

  if session[:battle_allies_config].blank? || @enemies.blank?
    session[:battle_error] = "艦隊配置または敵データが不足しています。編成フェーズからやり直してください。"
    redirect '/battle/set'
  end

  @battle_allies_deployed = true
  @battle_allies_positions = (session[:battle_allies_config] || []).map do |a|
    fleet_data = @fleets.find_by(fleet_number: a[:fleet_number])
    flagship = fleet_data && UserMyfreet.find_by(id: fleet_data.flagship_id)
    flagship_hp = flagship&.allfreet&.hp.to_i
    sub_hp_total = (1..6).sum do |i|
      ship_id = fleet_data&.send("sub_ship_#{i}_id")
      sub = ship_id.present? && UserMyfreet.find_by(id: ship_id)
      sub ? sub.allfreet.hp : 0
    end
    {
      col: a[:col].to_i,
      row: a[:row].to_i,
      fleet_number: a[:fleet_number],
      hp: flagship_hp + sub_hp_total,
      max_hp: flagship_hp + sub_hp_total
    }
  end

  # 🚢 【味方艦船データのロード】
  deployed_allies = []
  (session[:battle_allies_config] || []).each do |config|
    fleet_num = config[:fleet_number]
    fleet_data = @fleets.find_by(fleet_number: fleet_num)
    next unless fleet_data

    # 👑 旗艦
    flagship = UserMyfreet.find_by(id: fleet_data.flagship_id)
    if flagship && flagship.allfreet
      deployed_allies << {
        name: flagship.allfreet.name,
        speed: flagship.allfreet.speed.to_i,
        skill1_name: flagship.allfreet.skill1&.name || "なし",
        skill2_name: flagship.allfreet.skill2&.name || "なし",
        skill3_name: flagship.allfreet.skill3&.name || "なし",
        side: "味方",
        fleet: "第#{fleet_num}艦隊 (旗艦)"
      }
    end

    # ⚓ 随伴艦
    (1..6).each do |i|
      ship_id = fleet_data.send("sub_ship_#{i}_id")
      next if ship_id.blank?
      sub_ship = UserMyfreet.find_by(id: ship_id)
      if sub_ship && sub_ship.allfreet
        deployed_allies << {
          name: sub_ship.allfreet.name,
          speed: sub_ship.allfreet.speed.to_i,
          skill1_name: sub_ship.allfreet.skill1&.name || "なし",
          skill2_name: sub_ship.allfreet.skill2&.name || "なし",
          skill3_name: sub_ship.allfreet.skill3&.name || "なし",
          side: "味方",
          fleet: "第#{fleet_num}艦隊 (随伴)"
        }
      end
    end
  end

  # 👾 【敵艦船データのロード】
  deployed_enemies = []
  @enemies.each do |enemy_unit|
    # 👑 敵旗艦
    ef_flag = EnemyFreet.find_by(id: enemy_unit[:flagship][:id])
    if ef_flag && ef_flag.allfreet
      deployed_enemies << {
        name: ef_flag.allfreet.name,
        speed: ef_flag.allfreet.speed.to_i,
        skill1_name: ef_flag.allfreet.skill1&.name || "なし",
        skill2_name: ef_flag.allfreet.skill2&.name || "なし",
        skill3_name: ef_flag.allfreet.skill3&.name || "なし",
        side: "敵",
        fleet: "#{enemy_unit[:name]} (旗艦)"
      }
    end

    # ⚓ 敵随伴艦
    (enemy_unit[:sub_ships] || []).each do |sub|
      ef_sub = EnemyFreet.find_by(id: sub[:id])
      if ef_sub && ef_sub.allfreet
        deployed_enemies << {
          name: ef_sub.allfreet.name,
          speed: ef_sub.allfreet.speed.to_i,
          skill1_name: ef_sub.allfreet.skill1&.name || "なし",
          skill2_name: ef_sub.allfreet.skill2&.name || "なし",
          skill3_name: ef_sub.allfreet.skill3&.name || "なし",
          side: "敵",
          fleet: "#{enemy_unit[:name]} (随伴)"
        }
      end
    end
  end

  # ⚡ 【速力順ソート（同じ速力ならランダムに決定）】
  # shuffleで並び順をランダム化した後に、sort_byで速力の降順にソートすることで、同速艦の順序をランダム化します。
  @sorted_ships = (deployed_allies + deployed_enemies).shuffle.sort_by { |s| -s[:speed] }

  @prep_logs = session[:battle_logs].presence || ["哨戒戦技を展開中…！艦隊配置は完了しています。"]
  session[:battle_phase] = 'prepare'

  erb :battle
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

  puts "====== /battle/turn 到達 ======"
  puts "session[:battle_allies_config] = #{session[:battle_allies_config].inspect}"
  puts "session[:battle_enemies] = #{session[:battle_enemies].inspect}"
  puts "========================================"

  # 💾 セッションに保存された配置情報から詳細データを再構築
  if session[:battle_allies_config].blank? || session[:battle_enemies].blank?
    redirect '/battle/set'
  end

  # 🔨 味方データの再構築
  @allies = []
  session[:battle_allies_config].each do |config|
    fleet_num = config[:fleet_number]
    fleet_data = @user.user_battleunits.find_by(fleet_number: fleet_num)
    next unless fleet_data

    flagship = UserMyfreet.find_by(id: fleet_data.flagship_id)
    next unless flagship

    base_flag_hp = flagship.allfreet.hp
    base_flag_hp *= 10 if fleet_num == 1

    flagship_data = { id: fleet_data.flagship_id, hp: base_flag_hp, max_hp: base_flag_hp }

    sub_ships_data = []
    (1..6).each do |i|
      ship_id = fleet_data.send("sub_ship_#{i}_id")
      next if ship_id.blank?
      sub_ship = UserMyfreet.find_by(id: ship_id)
      if sub_ship
        sub_ships_data << { id: ship_id, hp: sub_ship.allfreet.hp, max_hp: sub_ship.allfreet.hp }
      end
    end

    @allies << {
      fleet_number: fleet_num,
      name: "第#{fleet_num}艦隊",
      col: config[:col],
      row: config[:row],
      flagship: flagship_data,
      sub_ships: sub_ships_data
    }
  end

  # 🔨 敵データは既存セッションの詳細データをそのまま使う
  @enemies = session[:battle_enemies] || []

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
  @battle_allies_deployed = @allies.present? || session[:battle_allies_config].present?
  @battle_allies_positions = if @allies.present?
    @allies.map do |a|
      sub_hp_total = a[:sub_ships].sum { |s| s[:hp] }
      total_hp = a[:flagship][:hp] + sub_hp_total
      total_max = a[:flagship][:max_hp] + a[:sub_ships].sum { |s| s[:max_hp] }
      { col: a[:col].to_i, row: a[:row].to_i, fleet_number: a[:fleet_number], hp: total_hp, max_hp: total_max }
    end
  else
    (session[:battle_allies_config] || []).map do |a|
      fleet_data = @fleets.find_by(fleet_number: a[:fleet_number])
      flagship = fleet_data && UserMyfreet.find_by(id: fleet_data.flagship_id)
      flagship_hp = flagship&.allfreet&.hp.to_i
      sub_hp_total = (1..6).sum do |i|
        ship_id = fleet_data&.send("sub_ship_#{i}_id")
        sub = ship_id.present? && UserMyfreet.find_by(id: ship_id)
        sub ? sub.allfreet.hp : 0
      end
      { col: a[:col].to_i, row: a[:row].to_i, fleet_number: a[:fleet_number], hp: flagship_hp + sub_hp_total, max_hp: flagship_hp + sub_hp_total }
    end
  end
  puts "@battle_allies_positions = #{@battle_allies_positions.inspect}"
  @phase = 'turn'
  session[:battle_phase] = 'turn'

  erb :battle
end

# 🏁 【新設】戦闘結果画面を表示する処理
get '/battle/result' do
  # 1. 画面が求めている「@finaresult」に、日本語の「勝利」か「敗北」をセット
  @finaresult = (session[:battle_result] == "win") ? "勝利" : "敗北"
  
  # 2. 画面の19行目がエラーにならないよう、セッションにある味方データを渡す
  raw_units = session[:battle_allies] || []
  @my_units = raw_units.map do |u|
    ship_list = []
    # 👑 1. まずは「旗艦」のデータを登録
    current_hp = u[:flagship][:hp]
    max_hp     = u[:flagship][:max_hp]
    flagship_obj = UserMyfreet.find_by(id: u[:flagship][:id])
    master_ship  = flagship_obj&.allfreet
    
    ship_list << {
      'level' => flagship_obj&.level || 1,
      'exp'   => flagship_obj&.exp || 0,
      'myfreet' => {
        'id'     => u[:flagship]['id'],
        'name'   => master_ship ? master_ship.name : u[:name],
        'hp'     => current_hp,
        'max_hp' => max_hp,
        'atk'    => master_ship ? master_ship.atk : 25,
        'info'   => master_ship ? master_ship.info || "てんぷれーと" : "てんぷれーと"
      }
    }
    # ⚓ 2. 続いて、この艦隊に所属する「随伴艦」たちを全員登録
    (u[:sub_ships] || []).each do |sub|
      sub_obj = UserMyfreet.find_by(id: sub[:id])
      sub_master = sub_obj&.allfreet
      next unless sub_master # 万が一DBから消えていたらスキップ

      ship_list << {
        'level' => sub_obj&.level || 1,
        'exp'   => sub_obj&.exp || 0,
        'myfreet' => {
          'id'     => sub['id'],
          'name'   => sub_master.name,
          'hp'     => sub[:hp], # 戦闘後の残りHP
          'max_hp' => sub[:max_hp],
          'atk'    => sub_master.atk,
          'info'   => sub_master.info || "てんぷれーと"
        }
      }
    end
    ship_list
  end
  # ⭕ 以下の4行をピンポイントで追加（戦闘用セッションの後片付け）
  session[:battle_result]  = nil
  session[:battle_allies]  = nil
  session[:battle_enemies] = nil
  session[:battle_logs]    = nil
  
  erb :result
end