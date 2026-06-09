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

  # ❶ 画面から送られてきた「ガチャの種類」と「回数」を受け取る
  gacha_type = params[:gacha_type] # "normal" または "rare"
  roll_count = params[:roll_count].to_i # 1 または 10

  # ❷ ガチャの種類に応じて、データベースから持ってくる候補を切り替える
  #   大倉さんの設計通り、rare>0 なら自動的に味方2・3だけが選ばれます！
  if gacha_type == "rare"
    candidates = Allfreet.where("rare > 0")
    total_weight = candidates.sum(:rare)
  else
    candidates = Allfreet.where("normal > 0")
    total_weight = candidates.sum(:normal)
  end

  # 万が一、候補が空なら安全のために戻す
  redirect '/gacha' if candidates.empty?

  # ❸ 結果を格納する配列（バケツ）を用意
  results = []

  # ❹ 画面から指定された回数（1回 または 10回）だけループを回す！
  roll_count.times do
    random_point = rand(total_weight)
    selected_ship = nil
    current_weight = 0

    candidates.each do |ship|
      # ガチャの種類によって足す重みのカラムを切り替える
      weight = (gacha_type == "rare") ? ship.rare : ship.normal
      current_weight += weight

      if random_point < current_weight
        selected_ship = ship
        break
      end
    end

    results << selected_ship

    # データベースへの保存
    UserMyfreet.create(
      user_id: @user.id,
      myfreet_id: selected_ship.id,
      level: 1,
      exp: 0
    )
  end

  # ❺ 【ここがポイント】結果の表示分け
  # 単発（1回）なら、今まで通り単発用変数に。10連なら10連用変数に入れます。
  if roll_count == 1
    @rolled_ship = results.first
  else
    @rolled_ships = results
  end

  # 共通の結果表示画面（gacha.erb）を呼び出す
  erb :gacha
end