# ホーム画面関係
get '/home' do
  # ホーム画面を表示する
  if session[:user]
    # ユーザーを表示する
    @user=User.find(session[:user])
    # 所持艦情報を表示する
    @freets = @user.user_myfreets.includes(:myfreet).as_json(include: :myfreet) # 中間テーブルと関連データを取得
    session[:my_freets] = @freets.as_json
    puts @freets.as_json.inspect
    # 💡 [追記] 全体チャットの最新30件を、古い順（時系列順）で取得して画面に渡す
    # 最新の30件を降順で取ってから、画面表示のために reverse で昇順に戻しています
    @global_chats = Chat.where(category: 'global').order(created_at: :desc).limit(30).reverse
  end
    
  erb :home
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