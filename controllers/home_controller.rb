# ===========================
# 📚ホーム画面GET
# ===========================
get '/home' do
  # ユーザー認証チェック（削除禁止）
  @user = User.find_by(id: session[:user])
  redirect '/users/login' unless @user
  # 紫鉄アイテム所持数（count）
  @iron_count = @user.iron_count

  # 所持艦（object_id = 0）を取得
  @freets = @user.user_items
                 .where(object_id: 0)
                 .map do |item|
                   master = item.dictionary  # ← ここが新設計の正しい辞書参照

                   # 装備武器
                   weapon_master = item.weapon_item&.dictionary
                   weapon_name = weapon_master&.name || "なし"

                   # 搭載キャラ
                   char_master = item.character_item&.dictionary
                   char_name = char_master&.name || "なし"

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
  puts "🏠 ホーム画面の所持艦数: #{@freets.count}"
  @freets.each do |ship|
    puts "  - UserItem id=#{ship.id}, item_id=#{ship.item_id}"
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
    
  # イベントの有効化判定
  today = Date.today
  @active_events_raw = Event.where("start_date <= ? AND end_date >= ?", today, today)
  # イベントスケジュールから、現在有効なものを抽出
  @active_gacha    = @active_events_raw.where(event_type: 'gacha')
  @active_personal = @active_events_raw.where(event_type: 'personal')
  @active_alliance = @active_events_raw.where(event_type: 'alliance')
  
    
  erb :home
end
# ===========================
# 📚ホーム画面API
# ===========================
# APIとは、画面をリロードせずに、サーバーからデータを取得するための窓口のこと
# 📕ユーザー名を変更するAPI
post '/users/update_name' do
  # 1. ログインチェック（お馴染みの安全装置）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 2. 画面から送られてきた名前を取得し、前後の余計な空白を排除
  new_name = params[:name].to_s.strip
  # 3. バリデーション（空文字チェック ＆ 文字数制限など）
  if new_name.match?(/\A[^\s<>]{1,20}\z/)
    @user.update(name: new_name)
    session[:success] = "ユーザーネームを変更しました！"
  else
    session[:error] = "ユーザーネームは1文字以上、20文字以内で入力してください。"
  end
  # 4. ホーム画面（あるいは元の画面）へリダイレクト
  redirect '/home' # 💡 もしホームのURLが '/home' でなければ、実際のルートに合わせて書き換えてください
end
# 📕図鑑用の全艦艇データを取得するAPI
get '/api/ships' do
  # ログインチェック（未ログインなら401エラーを返すなど、セキュリティ用）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # ここから下は、全艦艇データをJSON形式で返す処理
  content_type :json
  ships = Allfreet.all # allfreetテーブルの全レコードを取得
  ships.to_json
end
# 📕ホーム画面からのチャット投稿を受け付けるAPI
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

  status 200
end
# 📕ホーム画面に最新チャットを返すAPI
get '/chat/global' do
  content_type :json

  chats = Chat.includes(:user)
              .where(category: 'global')
              .order(created_at: :desc)
              .limit(30)
              .sort_by(&:created_at)

  chats.map { |c|
    {
      id: c.id,
      user: c.user&.name || "???",
      body: c.body,
      time: c.created_at.strftime("%H:%M:%S")
    }
  }.to_json
end