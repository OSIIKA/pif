

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