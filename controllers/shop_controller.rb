# 📄 controllers/shop_controller.rb
# ===========================
# 📚ショップ画面GET
# ===========================
get '/shop' do
  # 💡 ログインしているユーザーのデータを取得（セッション管理の仕様に合わせて調整してください）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 🔩 紫鉄の所持数を取得（新設計対応）
  iron_item = Item.find_by(category: 1, rarity: 1)
  user_iron = @user.user_items.find_by(item_id: iron_item.id)
  @iron_count = user_iron ? user_iron.count : 0
  # 🛍️ ここで、views/shop.erb に渡す変数を設定
  @shop_items = Weapon.all.order(:rarity, :id) 
  @shop_items += Character.all.order(:rarity, :id) 
  @shop_items += Item.all.order(:rarity, :id)
  # 📝 デバッグ用にターミナルに出力
  puts "🟢 [SHOP] 所持紫鉄: #{@iron_count}個"
  puts "🟢 [SHOP] 商品一覧（#{@shop_items.count}件）"
  @shop_items.each do |item|
    puts "  - #{item.name} | レアリティ: #{item.rarity} | 価格: #{item.price} | カテゴリ: #{item.category_name}"
  end
  # views/shop.erb を読み込んで画面に表示する
  erb :shop
end