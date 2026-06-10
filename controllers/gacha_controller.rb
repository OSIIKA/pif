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
# 📄 controllers/gacha_controller.rb

# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
# ❶ 各ガチャ個別の入り口（ここでボーナス条件などを決める）
# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

# 🔵 通常ガチャの入り口
post '/gacha/normal' do
  roll_count = params[:roll_count].to_i
  # 通常ガチャは10連ボーナスは無し（false）で実行！
  execute_gacha("normal", roll_count, false)
end

# 🟡 レアガチャの入り口
post '/gacha/rare' do
  roll_count = params[:roll_count].to_i
  # 10連ガチャ（roll_countが10）のときだけ、ボーナスをON（true）にする！
  has_bonus = (roll_count == 10)
  
  execute_gacha("rare", roll_count, has_bonus)
end


# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
# ❷ 共通のガチャ実行メソッド（ここで実際の抽選と保存を行う）
# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
def execute_gacha(gacha_type, roll_count, bonus_active)
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  results = []

  # 指定された回数（1回 または 10回）だけループを回す
  # 「i」には、0, 1, 2 ... 9 と、現在の回数のインデックスが入ります
  roll_count.times do |i|
    
    # 🔥【蒼焔リスペクト】10連ボーナスの発動判定！
    # もし「10回目（iが9）」で、かつ「ボーナスがON」の場合
    if i == 9 && bonus_active
      # 🌟 10回目だけは「味方3（最高レア）」しか入っていない特別な箱にする！
      # （ここはお好みで "rarity: 3" など、大倉さんのマスターデータの仕様に合わせて調整してください）
      candidates = Allfreet.where(name: "味方3")
    else
      # 通常通りの箱（1〜9回目、または単発の場合）
      if gacha_type == "rare"
        candidates = Allfreet.where("rare > 0")
      else
        candidates = Allfreet.where("normal > 0")
      end
    end

    # 確率の合計を計算
    weight_column = (gacha_type == "rare") ? :rare : :normal
    total_weight = candidates.sum(weight_column)
    total_weight = 1 if total_weight == 0 # 安全装置

    random_point = rand(total_weight)
    selected_ship = nil
    current_weight = 0

    candidates.each do |ship|
      weight = (gacha_type == "rare") ? ship.rare : ship.normal
      current_weight += weight
      if random_point < current_weight
        selected_ship = ship
        break
      end
    end

    # 安全対策：万が一すり抜けた場合は先頭のキャラを入れる
    selected_ship ||= candidates.first
    results << selected_ship

    # データベースへ保存
    UserMyfreet.create(
      user_id: @user.id,
      myfreet_id: selected_ship.id,
      level: 1,
      exp: 0
    )
  end

  # 結果の割り振り（画面のERBがそのまま読み込めるようにします）
  if roll_count == 1
    @rolled_ship = results.first
  else
    @rolled_ships = results
  end

  # 共通の結果表示画面（gacha.erb）を呼び出す
  erb :gacha
end