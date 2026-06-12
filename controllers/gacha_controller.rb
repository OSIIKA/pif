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
  execute_gacha("normal", roll_count, false, nil)
end

# 🟡 レアガチャの入り口
post '/gacha/rare' do
  roll_count = params[:roll_count].to_i
  # 10連ガチャ（roll_countが10）のときだけ、ボーナスをON（true）にする！
  has_bonus = (roll_count == 10)
  # 🟢 10連ボーナスが発生した時に「狙い撃ちしたい条件」をここで指定して渡す！
  bonus_target = { rarity: 3 } # 例えば「レアリティ3のキャラだけが入った特別な箱」など
  execute_gacha("rare", roll_count, has_bonus, bonus_target)
end


# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
# ❷ 共通のガチャ実行メソッド（ここで実際の抽選と保存を行う）
# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
helpers do
  def execute_gacha(gacha_type, roll_count, bonus_active, bonus_condition)
    @user = User.find_by(id: session[:user])
    redirect '/users/new' if @user.nil?

    results = []
    # 🟢 【安全ガードを追加】もし、そもそもガチャの候補が1隻も登録されていなかったら強制送還する
    #test_box = (gacha_type == "rare") ? Allfreet.where("rare > 0") : Allfreet.where("normal > 0")
    #return redirect '/gacha' if test_box.empty? # ➔ 0件なら引かせずに安全に戻す

    # 指定された回数（1回 または 10回）だけループを回す
    # 「i」には、0, 1, 2 ... 9 と、現在の回数のインデックスが入ります
    roll_count.times do |i|
    
      # ＝＝＝＝＝ 🎯 ステップ1：まず「レア度（枠）」を決定する ＝＝＝＝＝
      if i == 9 && bonus_active
        # 10連ボーナス（確定枠）の時は、ルートから送られてきた条件（rarity: 3）を強制適用！
        selected_rarity = bonus_condition[:rarity]
      else
        # 通常時は、サイコロ（0〜99の乱数）を振って大枠のレア度を決定！
        dice = rand(100)
        
        if gacha_type == "rare"
          # 🟡 レアガチャの大枠確率設定（最高レア 5%、中堅レア 20%、低レア 75%）
          if dice < 5
            selected_rarity = 3  # 5%の確率で最高レア枠
          elsif dice < 25
            selected_rarity = 2  # 20%の確率で中堅レア枠
          else
            selected_rarity = 1  # 75%の確率で低レア枠
          end
        else
          # 🔵 通常ガチャの大枠確率設定（中堅レア 10%、低レア 90%）
          if dice < 10
            selected_rarity = 2  # 10%の確率で中堅レア枠
          else
            selected_rarity = 1  # 90%の確率で低レア枠
          end
        end
      end
    
      # ＝＝＝＝＝ 🎲 ステップ2：決まったレア度の中から「等確率」でキャラを1隻選ぶ ＝＝＝＝＝
      # 現在のガチャで排出対象（重みが0より大きい）かつ、選ばれたレア度のキャラをデータベースから探索
      weight_column = (gacha_type == "rare") ? :rare : :normal
      candidates = Allfreet.where(rarity: selected_rarity).where("#{weight_column} > 0")

      # 【安全装置】もしそのレア度のキャラが1隻も登録されていなかったら、全対象から選ぶ
      if candidates.empty?
        candidates = Allfreet.where("#{weight_column} > 0")
      end

      # 🟢 ここが大倉さんのアイデアの核心！
      # そのレア度の中にあるキャラ一覧から、完全に「等確率」でランダムに1隻を決定（圧縮）します！
      selected_ship = candidates.sample
      results << selected_ship

      # ＝＝＝＝＝ 💾 ステップ3：引いたキャラをユーザーの所持品（myfreets）に保存する ＝＝＝＝＝

      # データベースへ保存
      UserMyfreet.create(
        user_id: @user.id,
        myfreet_id: selected_ship.id,
        level: 1,
        exp: 0
      )
    end

    # ＝＝＝＝＝ 🎟️ レアガチャ限定：ガチャシール自動付与システム ＝＝＝＝＝
    if gacha_type == "rare"
      # 🟢 大倉さん設計：名前や生のIDは一切使わず、属性の組み合わせでアイテムを特定！
      # type: 2 (シール) かつ、レアガチャ用を示す rarity: 1 のアイテムを探す
      seal_item = Item.find_by(type: 2, rarity: 1)
      
      if seal_item
        user_item = @user.user_items.find_or_initialize_by(item_id: seal_item.id)
        user_item.count += roll_count
        user_item.save
      end
    end
    # ＝＝＝＝＝ 🎟️ ここまで ＝＝＝＝＝

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