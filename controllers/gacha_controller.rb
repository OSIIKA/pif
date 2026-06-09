# ガチャ画面を表示するルート
get '/gacha' do
  # ログインしているユーザーを確保（安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 最初はまだ引いていないので、結果は空っぽ
    @rolled_ship = nil
  # views/gacha.erb を読み込んで画面に表示する
  erb :gacha
end
# 🎲 ガチャボタンが押されたとき（新設）
post '/gacha/roll' do
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 📊 大倉さんがSeedsに登録したAllfreetから、ランダムに1件を神の悪戯（.sample）で抽出！
  @rolled_ship = Allfreet.all.sample

  # 結果（@rolled_ship）を持った状態で、もう一度ガチャ画面を描画する
  erb :gacha
end