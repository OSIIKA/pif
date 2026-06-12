# ガチャ画面を表示するルート
get '/gacha' do
  # ログインしているユーザーを確保（安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 🟢 ここを追記：URLの ?type= の文字を読み取る（指定がなければ "normal" にする）
  @gacha_type = params[:type] || "normal"
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
  # 🟢 10連ボーナスが発生した時に「狙い撃ちしたい条件」をここで指定して渡す！
  bonus_target = { rarity: 3 } # 例えば「レアリティ3のキャラだけが入った特別な箱」など
  execute_gacha("rare", roll_count, has_bonus)
end


# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
# ❷ 共通のガチャ実行メソッド（ここで実際の抽選と保存を行う）
# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
helpers do
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
        # 🟢 固定ではなく、ルートから送られてきた条件（例: nameが味方3）で動的にキャラを探す！
      candidates = Allfreet.where(bonus_condition)
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
    # 🟢 ここを追記：ガチャを引いた後も、選んでいたガチャの種類を画面に覚えさせる
    @gacha_type = gacha_type
    # 共通の結果表示画面（gacha.erb）を呼び出す
    erb :gacha
  end
end