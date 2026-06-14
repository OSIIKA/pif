

# 🟢 「艦隊」ボタンを押したときの通り道（ここが本番！）
get '/fleet' do
  # 1. ログインしているユーザーを取得
  @user = User.find(session[:user])
  
  # 2. そのユーザーが所持している艦船一覧を、マスターデータ（allfreet）と一緒に一気に取得
  @my_ships = @user.user_myfreets.includes(:allfreet)
  
  # 3. 艦隊画面（fleet.erb）を表示
  erb :fleet
end