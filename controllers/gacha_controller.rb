# 📄 controllers/gacha_controller.rb
# ===========================
# 📚ガチャ画面GET
# ===========================
get '/gacha' do
  # ログインしているユーザーを確保（安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 🟢 ここを追記：URLの ?type= の文字を読み取る（指定がなければ "normal" にする）
  @gacha_type = params[:type] || "normal"
  # 最初はまだ引いていないので、結果は空っぽ
  @rolled_ship = nil
  # 📅 🟢 ここから追記：期間限定ガチャの動的スケジュール判定システム
  if @gacha_type == "limited"
    today = Date.today

    # DB の events テーブルから「今日有効なガチャイベント」を検索
    active_schedule = Event.find_by(
      event_type: "gacha",
      start_date: ..Date.today,
      end_date: Date.today..
    )
    
    if active_schedule
      @gacha_title = active_schedule.name
      @limited_gacha_id = active_schedule.id
    else
      @gacha_title = "期間限定ガチャ（未開催）"
      @limited_gacha_id = nil
    end
  else
    @gacha_title = "常設レアガチャ"
  end
  # 🟢 ここまで
  # 📅 ガチャスケジュール一覧（開始日・終了日をそのまま表示）
  @gacha_schedules = Event.where(event_type: "gacha").order(:start_date)
  # views/gacha.erb を読み込んで画面に表示する
  erb :gacha
end
# ===========================
# 📕 通常ガチャ POST
# ===========================
post '/gacha/normal' do
  roll_count = params[:roll_count].to_i
  # 通常ガチャは10連ボーナスは無し（false）で実行！
  execute_gacha("normal", roll_count, false, nil)
  erb :gacha
end
# ===========================
# 📕 レアガチャ POST
# ===========================
post '/gacha/rare' do
  roll_count = params[:roll_count].to_i
  # 10連ガチャ（roll_countが10）のときだけ、ボーナスをON（true）にする！
  has_bonus = (roll_count == 10)
  # 🟢 10連ボーナスが発生した時に「狙い撃ちしたい条件」をここで指定して渡す！
  bonus_target = { rarity: 3 } # 例えば「レアリティ3のキャラだけが入った特別な箱」など
  execute_gacha("rare", roll_count, has_bonus, bonus_target)
  erb :gacha
end
# ===========================
# 📕 期間限定ガチャ POST
# ===========================
post '/gacha/limited' do
  roll_count = params[:roll_count].to_i
  # レアガチャと同じく、10連（roll_countが10）のときだけボーナスをON！
  has_bonus = (roll_count == 10)
  # 期間限定ガチャでもSR（rarity: 3）以上を確定枠にする場合
  bonus_target = { rarity: 3 }
  
  # 🟢 タイプを "limited" にして共通処理へ丸投げ！
  execute_gacha("limited", roll_count, has_bonus, bonus_target)
  # 📅 ガチャスケジュール一覧（開始日・終了日をそのまま表示）
  @gacha_schedules = Event.where(event_type: "gacha").order(:start_date)
  # 🟢 ログ出力を追加（デバッグ用）
  puts "🗓️ [GACHA] スケジュール件数: #{@gacha_schedules.count}"
  @gacha_schedules.each do |ev|
    puts "  - #{ev.name} | #{ev.start_date} 〜 #{ev.end_date}"
  end
  erb :gacha
end

# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
# 📚 共通のガチャ実行メソッド（ここで実際の抽選と保存を行う）
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
      UserItem.create!(
        user_id: @user.id,
        object_id: 0,              # 艦艇
        item_id: selected_ship.id, # Allfreet辞書ID
        level: 1,
        exp: 0,
        count: 1
      )
    end

    # ＝＝＝＝＝ 🎟️ レアガチャ限定：ガチャシール自動付与システム ＝＝＝＝＝
    if gacha_type == "rare"
      # 🟢 大倉さん設計：名前や生のIDは一切使わず、属性の組み合わせでアイテムを特定！
      # type: 2 (シール) かつ、レアガチャ用を示す rarity: 1 のアイテムを探す
      seal_item = Item.find_by(category: 2, rarity: 1)
      
      if seal_item
        user_item = @user.user_items.find_or_initialize_by(item_id: seal_item.id)
        user_item.count += roll_count
        user_item.save
      end
    end
    if gacha_type == "limited"
      # 🟢 大倉さん設計：名前や生のIDは一切使わず、属性の組み合わせでアイテムを特定！
      # type: 2 (シール) かつ、期間限定ガチャ用を示す rarity: 2 のアイテムを探す
      seal_item = Item.find_by(category: 2, rarity: 2)
      
      if seal_item
        user_item = @user.user_items.find_or_initialize_by(item_id: seal_item.id)
        user_item.count += roll_count
        user_item.save
      end
    end
    # ＝＝＝＝＝ 🎟️ ここまで ＝＝＝＝＝
    # 🎁 🟢 ここから追記：大倉さん特製 10連おまけアイテム配布システム
    # レアガチャか限定ガチャで、かつ10連（roll_countが10）の時だけ発動！
    if roll_count == 10 && (gacha_type == "rare" || gacha_type == "limited")
      # 👤 ユーザーの進捗レコードを取得。もし無ければその場で新規作成（初期値 step: 1）する！
      u_step = @user.usersteps || @user.create_usersteps(limited_gacha_step: 1)
      current_step = u_step.limited_gacha_step 
    
      # 🔍 大倉さんの指定条件：大分類(1) と 小分類(現在のステップ数) でタイムラインを検索！
      timeline_bonus = Itemtimeline.find_by(big_type: 1, small_type: 1, step: current_step)
    
      if timeline_bonus
        # タイムラインに設定されている外部キー（item_id）を使って、配るアイテムを特定
        bonus_item = Item.find_by(category: timeline_bonus.item_type, id: timeline_bonus.item_each_id)
        if bonus_item
          # ユーザーの所持品から対象アイテムを探す（なければ新枠作成）
          user_bonus = @user.user_items.find_or_initialize_by(item_id: bonus_item.id)
        
          # ❌ 固定の「+ 5」を廃止！
          # ⭕️ DBの「count」カラムに設定された不規則な数量（12個、49個など）をそのまま加算！
          user_bonus.count = (user_bonus.count || 0) + timeline_bonus.count
          # 🔄 🟢 ここを追記：大倉さん新提案の「シードの数だけ動的おまけ配布」ループシステム
          # 現在登録されている「ガチャおまけ（1, 1）」の総件数（今回は 6 件）をDBから自動カウント！
          max_step = Itemtimeline.where(big_type: 1, small_type: 1).count
        
          # 👤 ユーザーの進捗データ（u_step）のステップを進める
          if u_step.limited_gacha_step >= max_step
            u_step.limited_gacha_step = 1 # 登録された最大数を超えたら、自動で1回目に戻る！
          else
            u_step.limited_gacha_step += 1 # まだ上限に行ってなければ、次のステップへ
          end
        
          u_step.save # 忘れずに進捗データを保存！
          # 🔄 🟢 ここまで
          
          user_bonus.save
        
          puts "🎁 10連ボーナス！[#{current_step}回目] おまけとして「#{bonus_item.name}」を #{timeline_bonus.count} 個支給しました！"
        end
      end
    end
    # 🎁 🟢 ここまで追記
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

# ＝＝＝＝＝ 🤝 ガチャシール（天井）交換所の裏側処理 ＝＝＝＝＝
  post '/gacha/exchange' do
    # ログインチェック（念のため）
    @user = User.find_by(id: session[:user])
    redirect '/login' if @user.nil?
    
    # 画面から送られてきた「交換したいキャラのID」と「ガチャタイプ」を取得
    character_id = params[:target_character_id]
    gacha_type = params[:gacha_type]
    
    # 1. ユーザーの「レアガチャシール（type: 2, rarity: 1）」の所持データを取得
    seal_item = Item.find_by(type: 2, rarity: 1)
    user_seal = @user.user_items.find_by(item_id: seal_item.id) if seal_item
    
    # 安全対策：シールを持っていない、または10枚未満なら不正とみなして戻す
    if user_seal.nil? || user_seal.count < 10
      puts "🚨 エラー: シールが足りないか、データが存在しません"
      redirect "/gacha?type=#{gacha_type}"
    end
    
    # 2. 交換対象のキャラクターデータ（Allfreet）が存在するかチェック
    character_data = Allfreet.find_by(id: character_id)
    
    if character_data
      # 🟢 シールを10枚消費
      user_seal.count -= 10
      user_seal.save
      
      # 🟢 ユーザーの倉庫（UserFleet）にキャラクターを追加！
      # （既存のガチャ排出時のカラム設定に合わせて保存します）
      UserMyfreet.create(
        user_id: @user.id,
        myfreet_id: character_data.id,
        level: 1,
        exp: 0
      )
      
      puts "✨ 天井交換成功: #{character_data.name} を獲得しました！"
    end
    
    # 交換が終わったら、ガチャ画面にリダイレクトして戻す
    redirect "/gacha?type=#{gacha_type}"
  end
  # ＝＝＝＝＝ 🤝 ここまで ＝＝＝＝＝