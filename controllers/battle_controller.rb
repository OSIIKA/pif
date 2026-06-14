# バトル画面関係
get '/battle' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user
  # 📥 ストーリーから渡されたステージ番号を取得
  stage = session[:battle_stage]

  # 🏗️ いま編成されている大艦隊（第1〜第6）のデータを戦闘画面に引き渡す準備だけしておく
  @fleets = @user.user_battleunits.order(:fleet_number)
  # バトル画面を表示する
  erb :battle
end

get '/battle/lost' do
  @finaresult="敗北"
  erb :result
end
get '/battle/won' do
  @my_units = session[:my_freets]
  @enemy_units = session[:enemy_freets]
  @finaresult="勝利"
  # 現在のユーザーに関連する全てのUserMyfreetを取得
  user_myfreets = UserMyfreet.where(user_id: session[:user])
  # 各UserMyfreetに対してレベルを1増加
  user_myfreets.each do |user_myfreet|
    user_myfreet.update(exp: user_myfreet.exp + 100)
  end
  user_exp = User.where(id: session[:user])
  user_exp.each do |user_exp|
    user_exp.update(exp: user_exp.exp + 100)
  end
  erb :result
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