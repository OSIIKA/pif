

# 🟢 「艦隊」ボタンを押したときの通り道（ここが本番！）
get '/fleet' do
  # 1. ログインしているユーザーを取得
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user
  
  # 2. そのユーザーの「艦隊データ」を、6艦隊分まとめて取得（なければ自動初期化）
  # ⚙️ 🟢 自動初期化ロジック
  # 第1艦隊(1)〜第6艦隊(6)のレコードがなければ、その場で自動作成する
  (1..6).each do |num|
    @user.user_battleunits.find_or_create_by!(fleet_number: num)
  end

  # 📑 現在表示する艦隊番号を取得（指定がなければ第1艦隊にする）
  @current_fleet_num = (params[:fleet_num] || 1).to_i
  # 🧭 画面状態。最初はメニュー画面を見せ、ボタン押下で各画面へ遷移する
  @screen = params[:screen] || 'menu'
  
  # 🔍 選択された艦隊の編成データをピンポイントで取得
  @current_fleet = @user.user_battleunits.find_by(fleet_number: @current_fleet_num)

  # ⚓ 現在の艦隊に配備されている艦船データをそれぞれ取得する
  # （※大倉さんのプロジェクトの艦船所持テーブルやモデル名に合わせて適宜微調整してください。ここでは仮に「UserMyfreet」や「Item」から引く形を想定しています）
  @flagship = UserMyfreet.find_by(id: @current_fleet.flagship_id)
  @sub_ships = [
    UserMyfreet.find_by(id: @current_fleet.sub_ship_1_id),
    UserMyfreet.find_by(id: @current_fleet.sub_ship_2_id),
    UserMyfreet.find_by(id: @current_fleet.sub_ship_3_id),
    UserMyfreet.find_by(id: @current_fleet.sub_ship_4_id),
    UserMyfreet.find_by(id: @current_fleet.sub_ship_5_id),
    UserMyfreet.find_by(id: @current_fleet.sub_ship_6_id)
  ]

  # 3. そのユーザーが所持している艦船一覧を、マスターデータ（allfreet）と一緒に一気に取得
  @my_ships = @user.user_myfreets.includes(:allfreet)
  
  # 4. 艦隊画面（fleet.erb）を表示
  erb :fleet
end

# ⚔️ 🟢 ここを追記：艦船の配置・解除を実行するシステム
post '/fleet/set_ship' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user

  # 📥 どの艦隊の、どのスロット（旗艦 or 随伴1〜6）に、どの所持艦船を入れるか受け取る
  fleet_num = params[:fleet_num].to_i
  slot_type = params[:slot_type] # "flagship", "sub_1", "sub_2" ... "sub_6"
  chosen_ship_id = params[:user_myfreet_id].present? ? params[:user_myfreet_id].to_i : nil

  # 🔍 対象ユーザーの指定艦隊レコードを取得
  fleet = @user.user_battleunits.find_by(fleet_number: fleet_num)

  if fleet
    # 🔄 指定されたスロットのカラムをピンポイントで更新（空ならnilが入って解除になる）
    case slot_type
    when "flagship" then fleet.update(flagship_id: chosen_ship_id)
    when "sub_1"    then fleet.update(sub_ship_1_id: chosen_ship_id)
    when "sub_2"    then fleet.update(sub_ship_2_id: chosen_ship_id)
    when "sub_3"    then fleet.update(sub_ship_3_id: chosen_ship_id)
    when "sub_4"    then fleet.update(sub_ship_4_id: chosen_ship_id)
    when "sub_5"    then fleet.update(sub_ship_5_id: chosen_ship_id)
    when "sub_6"    then fleet.update(sub_ship_6_id: chosen_ship_id)
    end
  end

  # ✨ 配置が終わったら、選んでいた艦隊のタブを開いた状態でリダイレクト！
  redirect "/fleet?fleet_num=#{fleet_num}"
end