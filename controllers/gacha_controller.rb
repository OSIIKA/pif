# ガチャ画面を表示するルート
get '/gacha' do
  # ログインしているユーザーを確保（安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # views/gacha.erb を読み込んで画面に表示する
  erb :gacha
end