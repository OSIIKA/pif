# ホーム画面関係
get '/home' do
  # ホーム画面を表示する
  if session[:user]
    # ユーザー認証チェック（削除禁止）
    @user = User.find_by(id: session[:user])
    redirect '/users/login' unless @user
    # 所持艦（object_id = 0）を取得
    @freets = @user.user_items
                   .where(object_id: 0)
                   .includes(:allfreet)  # 辞書をJOIN
                   .map do |item|
                     master = item.allfreet
                     # 装備武器（UserItem）
                     weapon_item = item.weapon_id ? UserItem.find_by(id: item.weapon_id) : nil
                     weapon_name = weapon_item&.allfreet&.name || "なし"

                     # 装備キャラ（UserItem）
                     char_item = item.character_id ? UserItem.find_by(id: item.character_id) : nil
                     char_name = char_item&.allfreet&.name || "なし"
                     {
                       id: item.id,
                       level: item.level,
                       exp: item.exp,
                       name: master.name,
                       hp: master.hp,
                       atk: master.atk,
                       speed: master.speed,
                       rarity: master.rarity,
                       weapon_name: weapon_name,
                       char_name: char_name
                     }
                   end

    # セッションに巨大データを入れるのは危険なので廃止
    # session[:my_freets] = @freets
    # 所持艦一覧をターミナルに出力して確認（新設計対応）
    puts "🟢 [HOME] 所持艦一覧（#{@freets.size}件）"
    @freets.each do |f|
      puts "  - #{f[:name]} | HP: #{f[:hp]} | ATK: #{f[:atk]} | SPD: #{f[:speed]} | Lv: #{f[:level]}"
      puts "      武器: #{f[:weapon_name]} / キャラ: #{f[:char_name]}"
    end
    # 💡 [追記] 全体チャットの最新30件を、古い順（時系列順）で取得して画面に渡す
    latest_chats = Chat.where(category: 'global')
                       .order(created_at: :desc)
                       .limit(30)
    @global_chats = latest_chats.sort_by { |c| c.created_at }
    puts "💬 [HOME] 全体チャット（最新30件・昇順）"
    @global_chats.each do |chat|
      puts "  #{chat.created_at.strftime('%H:%M:%S')} | #{chat.user&.name || '???'}: #{chat.body}"
    end

    # イベントの有効化判定（RELEASE_DATE を基準に経過日で判定）
    begin
      current_day = (Date.today - RELEASE_DATE).to_i
    rescue => _e
      current_day = 0
    end

    # 期間指定のあるガチャスケジュールから、現在有効なものを抽出
    active_gacha = GACHA_SCHEDULES.select do |g|
      g[:start_day].to_i <= current_day && current_day <= g[:end_day].to_i
    end

    # PERSONAL / ALLIANCE の配列は start/end を持たない場合があるため、
    # start_day があればそれで判定、なければ常時有効と見なす
    active_personal = PERSONAL_EVENT_SCHEDULES.select do |e|
      if e.key?(:start_day)
        e[:start_day].to_i <= current_day && current_day <= e.fetch(:end_day, e[:start_day]).to_i
      else
        true
      end
    end

    active_alliance = ALLIANCE_EVENT_SCHEDULES.select do |e|
      if e.key?(:start_day)
        e[:start_day].to_i <= current_day && current_day <= e.fetch(:end_day, e[:start_day]).to_i
      else
        true
      end
    end

    # ビュー側で扱いやすいように総合的な配列を作る
    @active_events = []
    active_gacha.each { |g| @active_events << { id: g[:id], name: g[:name], type: 'gacha', color: '#ff8c00' } }
    active_personal.each { |e| @active_events << { id: e[:id], name: e[:name], type: 'personal', color: '#722ed1' } }
    active_alliance.each { |e| @active_events << { id: e[:id], name: e[:name], type: 'alliance', color: '#389e0d' } }

    # 後方互換性のため、必要であれば個別配列も渡す
    @personal_events = active_personal
    @alliance_events = active_alliance
  end
    
  erb :home
end

post '/users/update_name' do
  # 1. ログインチェック（お馴染みの安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 2. 画面から送られてきた名前を取得し、前後の余計な空白を排除
  new_name = params[:name].to_s.strip

  # 3. バリデーション（空文字チェック ＆ 文字数制限など）
  if new_name.present? && new_name.length <= 20
    @user.update(name: new_name)
    session[:success] = "ユーザーネームを変更しました！"
  else
    session[:error] = "ユーザーネームは1文字以上、20文字以内で入力してください。"
  end

  # 4. ホーム画面（あるいは元の画面）へリダイレクト
  redirect '/home' # 💡 もしホームのURLが '/home' でなければ、実際のルートに合わせて書き換えてください
end

# 図鑑用の全艦艇データを取得するAPI
# APIとは、画面をリロードせずに、サーバーからデータを取得するための窓口のこと
get '/api/ships' do
  # ログインチェック（未ログインなら401エラーを返すなど、セキュリティ用）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # ここから下は、全艦艇データをJSON形式で返す処理
  content_type :json
  ships = Allfreet.all # allfreetテーブルの全レコードを取得
  ships.to_json
end

# 💡 [新規追加] ホーム画面からのチャット投稿を受け付ける窓口
post '/home/chat' do
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 新しい発言をデータベースに保存
  # 保存された瞬間に、chat.rb側の「500件お掃除ロジック」が自動発動します！
  Chat.create(
    user_id: @user.id,
    body: params[:chat_body],
    category: 'global'
  )

  # 書き込みが終わったら、ホーム画面にリダイレクトして最新のチャットを表示
  redirect '/home?chat=open'
end
