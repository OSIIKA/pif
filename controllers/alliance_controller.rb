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
  # 1. ログインしているユーザーを取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 2. フォームから届いた名前で、新しい同盟のデータを準備
  # 盟主（leader_id）には、作った本人のIDを叩き込みます
  alliance = Alliance.new(
    name: params[:alliance_name],
    leader_id: @user.id,
    level: 1,
    exp: 0
  )

  # 3. データベースへの保存に挑戦
  if alliance.save
    # 💡 結成に成功したら、作った本人の「所属同盟ID」も更新してあげる
    @user.update(alliance_id: alliance.id)
    
    # 完了したら同盟ページ（再読み込み）へ戻る
    # 次は所属状態になっているので、自動的に「ダッシュボード画面」に切り替わります！
    redirect '/alliance'
  else
    # 万が一、同盟名が重複していたり空欄だった場合はエラーを持って未所属画面を再表示
    @error = alliance.errors.full_messages.join(', ')
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