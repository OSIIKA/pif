get '/alliance' do
  # 💡 ログインしているユーザーのデータを取得（セッション管理の仕様に合わせて調整してください）
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil? # ログインしていなければ登録画面へ

  # 💡 ユーザーが同盟に所属しているかどうかで、表示する中身を完全に切り替える
  if @user.alliance.nil?
    # 👇 世の中のすべての同盟を取得して画面に渡す
    @alliances = Alliance.all
    erb :alliance_none # 未所属画面（同盟の結成・検索）
  # 🟢 追記：もし役職が「1（参加申請中）」なら、専用の待機画面を表示してガードする！
  elsif @user.alliance_role == 1
    @alliance = @user.alliance # 画面に「〇〇同盟に申請中」と出すために情報を取得
    erb :alliance_pending      # 👈 新しい待機画面を呼び出す
  else
    @alliance = @user.alliance
    # 💡 この同盟のチャット最新30件を古い順（時系列順）で取得
    @alliance_chats = Chat.where(alliance_id: @alliance.id, category: 'alliance')
                          .order(created_at: :desc)
                          .limit(30)
                          .reverse
    # 1. 先にHTMLをレンダリングして変数にキープする（この時点ではまだ未読扱いなので赤ポチがつく！）
    html_output = erb :alliance_dashboard
    
    # 2. 画面の組み立てが終わったので、この瞬間の申請者数を記憶する（既読にする）
    session[:last_checked_request_count] = User.where(alliance_id: @user.alliance_id, alliance_role: 1).count
    
    # 3. 組み立てておいたHTMLをブラウザに返す
    html_output
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
    # 🟢 変更：同盟のタイプ（join_type）によって、初期ロールを自動で振り分ける
    if alliance.join_type == 'approval'
      # 要申請なら、ロール「1」（参加申請中）で紐付ける
      @user.update(alliance_id: alliance.id, alliance_role: 1)
    else
      # 安全確認：ユーザーが存在し、かつ自分と同じ同盟への「申請中（ロール1）」である場合のみ処理
      if target_user && target_user.alliance_id == @user.alliance_id && target_user.alliance_role == 1
        # 🌟 ロールを「2（通常メンバー）」に引き上げる！
        target_user.update(alliance_role: 2)
        # 🟢 追加：チャットに「参加ログ」を自動投稿（ID: 1 = システムユーザー）
        Chat.create!(
          user_id: 1,
          category: "alliance",
          alliance_id: @user.alliance_id,
          body: "#{target_user.name}さんが参加しました"
        )
      end
    end
    
    # 所属状態になったので、リロードすれば自動的に「同盟マイページ」へ切り替わる
    redirect '/alliance'
  else
    # 万が一、同盟が解散されていたりして見つからなかった場合
    session[:error] = "指定された同盟が見つかりませんでした。"
    redirect '/alliance'
  end
end

# 🟢 追記：参加申請を「許可」する処理
post '/alliance/approve' do
  # 1. ログインしている役職3以上の偉い人（盟主・副盟主）を取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  # 🚨 セキュリティ：副盟主未満（2以下）なら不正アクセスとして弾く
  redirect '/alliance' if @user.alliance_role < 3

  # 2. 画面から送られてきた user_id を使って、申請中のユーザーを探す
  target_user = User.find_by(id: params[:user_id])
  
  # 安全確認：ユーザーが存在し、かつ自分と同じ同盟への「申請中（ロール1）」である場合のみ処理
  if target_user && target_user.alliance_id == @user.alliance_id && target_user.alliance_role == 1
    # 🌟 ロールを「2（通常メンバー）」に引き上げる！
    target_user.update(alliance_role: 2)
    # 🟢 追加：チャットに「参加ログ」を自動投稿（ID: 1 = システムユーザー）
    Chat.create!(
      user_id: 1,
      category: "alliance",
      alliance_id: @user.alliance_id,
      body: "#{target_user.name}さんが参加しました"
    )
  end

  redirect '/alliance'
end

# 🟢 追記：参加申請を「拒否」する処理
post '/alliance/reject' do
  # 1. ログインしている役職3以上の偉い人を取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  redirect '/alliance' if @user.alliance_role < 3

  # 2. 対象の申請中ユーザーを探す
  target_user = User.find_by(id: params[:user_id])
  
  if target_user && target_user.alliance_id == @user.alliance_id && target_user.alliance_role == 1
    # 🌟 同盟の紐付けを解除し、ロールも「0（無所属）」に突き落とす！
    target_user.update(alliance_id: nil, alliance_role: 0)
  end

  redirect '/alliance'
end

post '/alliance/promote' do
  # 1. ログイン中のユーザーを取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  
  # 🚨 権限チェック：盟主（4）以外からのアクセスは即弾く
  redirect '/alliance' if @user.alliance_role != 4

  # 2. 変更対象のメンバーを取得
  target_user = User.find_by(id: params[:user_id])

  # 🚨 安全確認：同じ同盟、かつ現在の役職が「通常メンバー(2)」の場合のみ
  if target_user && target_user.alliance_id == @user.alliance_id && target_user.alliance_role == 2
    # ⚔️ 副盟主（3）に昇格！
    target_user.update(alliance_role: 3)
  end

  redirect '/alliance'
end

post '/alliance/demote' do
  # 1. ログイン中のユーザーを取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  
  # 🚨 権限チェック：盟主（4）以外からのアクセスは即弾く
  redirect '/alliance' if @user.alliance_role != 4

  # 2. 変更対象のメンバーを取得
  target_user = User.find_by(id: params[:user_id])

  # 🚨 安全確認：同じ同盟、かつ現在の役職が「副盟主(3)」の場合のみ
  if target_user && target_user.alliance_id == @user.alliance_id && target_user.alliance_role == 3
    # 👥 通常メンバー（2）に降格
    target_user.update(alliance_role: 2)
  end

  redirect '/alliance'
end

post '/alliance/kick' do
  # 1. ログイン中のユーザーを取得
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?
  
  # 🚨 権限チェック：副盟主以上（3以上）でなければ即弾く
  redirect '/alliance' if @user.alliance_role < 3

  # 2. 追放対象のメンバーを取得
  target_user = User.find_by(id: params[:user_id])

  if target_user && target_user.alliance_id == @user.alliance_id
    # 🚨 安全確認：自分より下の役職のメンバーのみ追放可能に！
    # （盟主4なら3と2、副盟主3なら2のみを許可する超安全設計です）
    if @user.alliance_role > target_user.alliance_role
      # 💥 同盟の紐付けを解除し、ロールを「0（無所属）」に戻す
      target_user.update(alliance_id: nil, alliance_role: 0)
    end
  end

  redirect '/alliance'
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
    # 🔴 追加：同盟を抜ける前に、チャットへ「脱退ログ」を自動投稿（ID: 1 = システムユーザー）
    Chat.create!(
      user_id: 1,
      category: "alliance",
      alliance_id: @alliance.id, # 👈 キープしてある@allianceのIDを使うので絶対に安全！
      body: "#{@user.name}さんが脱退しました"
    )
    # 一般メンバーなら安全に無所属（nil）にしてホーム画面へお見送り
    @user.update(alliance_id: nil, alliance_role: 0)
    redirect '/home'
  end
end

# 💡 追加：同盟解散処理（POST）
post '/alliance/disband' do
  # 1. ログインユーザーのチェック
  @user = User.find_by(id: session[:user])
  redirect '/users/new' if @user.nil?

  # 2. ユーザーが所属している同盟を取得
  alliance = Alliance.find_by(id: @user.alliance_id)

  # 安全のためのガード：本当に盟主か、かつメンバーが自分1人だけかをサーバー側でもチェック
  if @user.alliance_role == 4 && alliance && alliance.users.count == 1
    
    # 💡 処理A：盟主自身の同盟情報をリセット（無所属、役職0にする）
    @user.update(
      alliance_id: nil,
      alliance_role: 0
    )

    # 💡 処理B：同盟データをデータベースから完全に削除
    alliance.destroy

    # 解散完了！未所属用のページへリダイレクト
    redirect '/alliance'
  else
    # 万が一、条件を満たしていないのにアクセスされた場合は何もせずマイページに戻す
    redirect '/alliance'
  end
end