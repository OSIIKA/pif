# 📄 controllers/shop_controller.rb
# ===========================
# 📚ショップ画面GET
# ===========================
get '/shop' do
  # 💡 ログインしているユーザーのデータを取得（セッション管理の仕様に合わせて調整してください）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 🛒 ショップの商品一覧を取得（Weaponモデルから全ての武器を取得）
  @shop_items = Weapon.all.order(:rarity, :id) # レアリティ順、ID順でソート

  # views/shop.erb を読み込んで画面に表示する
  erb :shop
end