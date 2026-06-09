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

  # 1. 通常ガチャの出現確率（normal）が0より大きい艦をすべて取得
  candidates = Allfreet.where("normal > 0")

  # 2. 全候補のウェイト（normal）の合計値を計算
  total_weight = candidates.sum(:normal)

  # 3. 0 から 総ウェイト未満 の間でランダムな数字（ダイス）を決める
  random_point = rand(total_weight)

  # 4. ダイスの目がどの艦のウェイト枠に落ちるかを計算して決定
  @rolled_ship = nil
  current_weight = 0

  candidates.each do |ship|
    current_weight += ship.normal
    if random_point < current_weight
      @rolled_ship = ship
      break
    end
  end

  # 5. 【重要】引いた艦をユーザーの所持艦隊（UserMyfreet）に新しく保存する
  # (前回の列名のズレを考慮して「myfreet_id」に当選したIDを入れます)
  UserMyfreet.create(
    user_id: @user.id,
    myfreet_id: @rolled_ship.id,
    level: 1,
    exp: 0
  )

  # ガチャ画面を再描画して、引いた艦の情報を表示する

  # 結果（@rolled_ship）を持った状態で、もう一度ガチャ画面を描画する
  erb :gacha
end

# 📄 コントローラーの末尾などに追記
post '/gacha/roll_ten' do
  @user = User.find(session[:user])

  # 通常ガチャの出現確率が0より大きい候補を集める
  candidates = Allfreet.where("normal > 0")
  total_weight = candidates.sum(:normal)

  # 🟢 10隻の結果を格納するための空の「配列（バケツ）」を用意する
  @rolled_ships = []

  # 🟢 10回連続で抽選を回す！
  10.times do
    random_point = rand(total_weight)
    selected_ship = nil
    current_weight = 0

    candidates.each do |ship|
      current_weight += ship.normal
      if random_point < current_weight
        selected_ship = ship
        break
      end
    end

    # 当選した艦を、この回の結果として配列に追加する
    @rolled_ships << selected_ship

    # プレイヤーの所持艦隊（データベース）に保存する
    UserMyfreet.create(
      user_id: @user.id,
      myfreet_id: selected_ship.id,
      level: 1,
      exp: 0
    )
  end

  # ガチャ画面を再描画（このとき @rolled_ships に10隻分のデータが入った状態になります）
  erb :gacha
end