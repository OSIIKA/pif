# バトル画面関係
get '/battle' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 📥 現在のステージ番号を取得（ストーリーから渡されたもの、無ければ1）
  @stage = session[:battle_stage] || 1

  # 📊 味方艦隊データの取得
  @fleets = @user.user_battleunits.order(:fleet_number)

  # 👾 🟢 ここを追記：このステージに配置されている敵艦隊をすべて取得
  @enemy_fleets = EnemyBattleunit.where(battle_stage_id: @stage)

  erb :battle
end

post '/battle/start' do
    @user = User.find_by(id: session[:user])
    redirect '/users/login' unless @user

    # 1. 味方の配置データをセッションに格納する配列
    battle_allies = []

    # 味方の全6艦隊をループして処理
    (1..6).each do |fleet_num|
      # フロントから届いた座標（例: "0,0"）を取得
      pos_str = params["fleet_#{fleet_num}_pos"]
      next if pos_str.blank? # 配置されていない艦隊はスルー

      col, row = pos_str.split(',').map(&:to_i)

      # DBから該当する味方艦隊の「塊」データを取得
      fleet_data = @user.user_battleunits.find_by(fleet_number: fleet_num)
      next unless fleet_data

      # 🧮 艦隊内の全生存艦のステータス（HP・攻撃力）を合計する
      total_hp = 0
      total_atk = 0
      skill_logs = []

      # ★【修正のキモ】味方の神経（アソシエーション）が無いため、IDから直接データベースを探しに行きます
      flagship = UserMyfreet.find_by(id: fleet_data.flagship_id)
      sub_1    = UserMyfreet.find_by(id: fleet_data.sub_ship_1_id)
      sub_2    = UserMyfreet.find_by(id: fleet_data.sub_ship_2_id)
      sub_3    = UserMyfreet.find_by(id: fleet_data.sub_ship_3_id)
      sub_4    = UserMyfreet.find_by(id: fleet_data.sub_ship_4_id)
      sub_5    = UserMyfreet.find_by(id: fleet_data.sub_ship_5_id)
      sub_6    = UserMyfreet.find_by(id: fleet_data.sub_ship_6_id)

      # 旗艦と随伴艦1〜6をまとめてスキャン（存在するものだけを配列にする）
      ships = [
        { ship: flagship, is_flag: true },
        sub_1, sub_2, sub_3, sub_4, sub_5, sub_6
      ].compact # nil（空スロット）を除外

      ships.each do |item|
        ship = item.is_a?(Hash) ? item[:ship] : item
        next unless ship

        # マスタ（Allfreet）から素のステータスを取得
        base_hp = ship.allfreet.hp
        base_atk = ship.allfreet.atk

        # 👑 【今回の特別ルール】第一艦隊の旗艦だけ10倍にする
        if fleet_num == 1 && item.is_a?(Hash) && item[:is_flag]
          base_hp *= 10
          base_atk *= 10
          skill_logs << "第一艦隊旗艦戦技：【臨界突破・十倍界王拳】発動！"
        end

        total_hp += base_hp
        total_atk += base_atk
      end

      # セッション用の綺麗なハッシュにして保管
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

    # 味方のデータをセッションにセーブ
    session[:battle_allies] = battle_allies

    # 2. 敵のデータも同様にDB（シードで入れたやつ）からセッションにコピー
    stage = (params[:stage] || 1).to_i
    enemy_units = EnemyBattleunit.where(battle_stage_id: stage)
    
    session[:battle_enemies] = enemy_units.map do |unit|
      # 敵も同様に旗艦＋随伴のステータスを合計（ここでは簡易的に旗艦のステータスベース）
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

    # 戦闘ログの初期化
    session[:battle_logs] = []

    # 次の「準備フェーズ」画面へジャンプ！
    redirect '/battle/prepare'
  end

get '/battle/prepare' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # セッションから戦闘データとログをビューに引き渡す
  @allies = session[:battle_allies]
  @enemies = session[:battle_enemies]
  
  # ここで「準備フェーズのログ」を一時的に作ってビューに渡す
  @prep_logs = []
  @allies.each do |fleet|
    if fleet[:skills].any?
      fleet[:skills].each { |s| @prep_logs << "【味方】#{fleet[:name]} - #{s}" }
    end
  end
  
  @prep_logs << "両軍、布陣完了。これより戦闘フェーズに移行します！" if @prep_logs.empty?

  erb :battle_prepare
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