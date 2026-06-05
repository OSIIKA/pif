get '/alliance' do
  # 💡 ログインしているユーザーのデータを取得（セッション管理の仕様に合わせて調整してください）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil? # ログインしていなければ登録画面へ

  # 💡 ユーザーが同盟に所属しているかどうかで、表示する中身を完全に切り替える
  if @user.alliance.nil?
    # 👇 この1行を追加！世の中のすべての同盟を取得して画面に渡す
    @alliances = Alliance.all
    erb :alliance_none # 未所属画面（同盟の結成・検索）
  else
    @alliance = @user.alliance
    # 💡 [追記] この同盟のチャット最新30件を古い順（時系列順）で取得
    @alliance_chats = Chat.where(alliance_id: @alliance.id, category: 'alliance')
                          .order(created_at: :desc)
                          .limit(30)
                          .reverse
    erb :alliance_dashboard # 所属済み画面（同盟のマイページ）
  end
end

post '/alliance/create' do
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 1. 画面から届いた join_type ("public" または "approval") を含めて同盟を作成
  alliance = Alliance.new(
    name: params[:alliance_name],
    join_type: params[:join_type], # 💡 追加：加入制限の文字列を格納
    leader_id: @user.id,
    level: 1,
    exp: 0
  )

  if alliance.save
    # 2. 💡 修正：結成した本人は所属IDを入れると同時に、役職を「4（盟主）」にする！
    @user.update(
      alliance_id: alliance.id,
      alliance_role: 4
    )
    redirect '/alliance'
  else
    @error = alliance.errors.full_messages.join(', ')
    @alliances = Alliance.all
    erb :alliance_none
  end
end

post '/alliance/join' do
  # 1. ログインしているユーザー（2人目）を取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 2. 画面から送られてきた同盟IDを使って、対象の同盟を探す
  alliance = Alliance.find_by(id: params[:alliance_id])

  if alliance
    # 💡 ユーザーの所属同盟IDを、見つかった同盟のIDで更新する！
    @user.update(alliance_id: alliance.id)
    
    # 所属状態になったので、リロードすれば自動的に「同盟マイページ」へ切り替わる
    redirect '/alliance'
  else
    # 万が一、同盟が解散されていたりして見つからなかった場合
    session[:error] = "指定された同盟が見つかりませんでした。"
    redirect '/alliance'
  end
end

# 💡 [新規追加] 同盟チャットの投稿を受け付ける窓口
post '/alliance/chat' do
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  
  # 無所属の不正ポストをガード
  redirect '/alliance' if @user.alliance_id.nil?

  # 同盟IDを紐づけてチャットを保存
  # 保存された瞬間に、chat.rb側の「同盟ごと200件お掃除ロジック」が自動発動！
  Chat.create(
    user_id: @user.id,
    alliance_id: @user.alliance_id,
    body: params[:chat_body],
    category: 'alliance'
  )

  # 連続で喋れるように「?chat=open」をつけて同盟ページに戻すおもてなし
  redirect '/alliance?chat=open'
end

# 📝 controllers/alliance_controller.rb

# 同盟脱退の処理
post '/alliance/leave' do
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  @alliance = @user.alliance
  redirect '/alliance' if @alliance.nil?

  # 💡 盟主の防衛策：自分が盟主なら脱退させずにエラーを返す
  if @alliance.leader_id == @user.id
    session[:error] = "盟主は同盟を脱退できません。解散するか、他メンバーに盟主を譲渡してください。"
    redirect '/alliance'
  else
    # 一般メンバーなら安全に無所属（nil）にしてホーム画面へお見送り
    @user.update(alliance_id: nil)
    redirect '/home'
  end
end