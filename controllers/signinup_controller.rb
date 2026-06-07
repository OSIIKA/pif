# 新規登録・ログイン関係
get '/users/new' do
    # 新規登録画面を表示する
    @error = session.delete(:error) # セッションからエラーを取り出し、同時に中身を消去（リロードで消えるようにする）
    @user = User.new # 👈 空のユーザーを用意しておく（画面側でのエラー防止）
    erb :sign_up
end
post '/users/new' do
    # 新規登録をする（create ではなく new にして @user に格納する）
    @user = User.new(name: params[:name], mail: params[:mail], password: params[:password], password_confirmation: params[:password_confirmation], level: 1, exp: 0)
    if @user.save
      # ユーザーが正常に保存された場合にユニットを関連付ける
      default_units = [1, 2, 3].map do |i|
        Myfreet.find_or_create_by(id: i) do |f|
          f.name = "ユニット#{i}"
        end
      end
      default_units.each do |unit|
        UserMyfreet.create(user_id: @user.id, myfreet_id: unit.id, level: 1, exp: 0)
      end
      session[:user] = @user.id
      redirect '/home'
    else
      erb :sign_up
    end
end
get '/users/login' do
    # ログイン画面を表示する
    @error = session.delete(:error) # セッションからエラーを取り出し、同時に中身を消去（リロードで消えるようにする）
    erb :sign_in
end
post '/users/login' do
  # ログインをする
  user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
      session[:user] = user.id
      redirect '/home'
    else
      # エラーメッセージを変数に入れて、ログイン画面をそのまま再描画する
      @error = "ユーザー名またはパスワードが正しくありません"
      erb :sign_in
    end
end

# ログアウト処理
get '/users/logout' do
  session.clear # セッション情報をすべて消去
  redirect '/users/login'
end

# ======= 👇 ここからGoogleログインのお出迎えコードを追加 👇 =======

# Googleからデータを持って帰ってきたときの受付窓口
get '/auth/google_oauth2/callback' do
  auth = request.env['omniauth.auth'] # Googleから届いたユーザー情報（名前やメールなど）
  
  # すでにこのGoogleアカウントで登録されているユーザーを探す。いなければ新しく準備する。
  user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
  
  # まだデータベースに保存されていない「ご新規さん」の場合の処理
  if user.new_record?
    user.name = auth.info.name
    user.mail = auth.info.email
    
    # 💡 パスワード認証用の仕組み（has_secure_password）を突破するために、仮のランダムパスワードをセット
    temporary_password = SecureRandom.hex(16)
    user.password = temporary_password
    user.password_confirmation = temporary_password
    
    user.level = 1
    user.exp = 0
    
    if user.save
      # 新規登録成功時に、初期ユニット（1, 2, 3）をプレゼントする処理（既存の新規登録と同じ）
      default_units = [1, 2, 3].map do |i|
        Myfreet.find_or_create_by(id: i) do |f|
          f.name = "ユニット#{i}"
        end
      end
      default_units.each do |unit|
        UserMyfreet.create(user_id: user.id, myfreet_id: unit.id, level: 1, exp: 0)
      end
    else
      # 💡 変更：ターミナルに出すだけでなく、セッションにエラー内容を詰めて「新規登録画面」に戻す
      session[:error] = "Googleアカウントでの登録に失敗しました: #{user.errors.full_messages.join(', ')}"
      redirect '/users/new'
      return
    end
  end
  
  # ログイン状態にしてホーム画面へドン！
  session[:user] = user.id
  redirect '/home'
end

# Googleログイン自体を途中でキャンセルしたり失敗したときの逃げ道
get '/auth/failure' do
  # 💡 変更：こちらもエラーメッセージを持って「新規登録画面」に戻す
  session[:error] = "Google認証がキャンセルされたか、失敗しました。"
  redirect '/users/new'
end

# ======= 👆 ここまで 👆 =======

# ======= 👇 ここからX（Twitter）ログインのお出迎えコードを追加 👇 =======

# Xからデータを持って帰ってきたときの受付窓口
get '/auth/twitter2/callback' do
  auth = request.env['omniauth.auth'] # Xから届いたユーザー情報
  
  # すでにこのXアカウントで登録されているユーザーを探す。いなければ新しく準備する。
  user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
  
  # まだデータベースに保存されていない「ご新規さん」の場合の処理
  if user.new_record?
    # Xの表示名（無ければ @ユーザー名）を取得
    user.name = auth.info.name || auth.info.nickname
    
    # 💡 安全装置：Xからメールアドレスが取れなかった場合は、一意の仮アドレスを自動生成
    user.mail = auth.info.email || "twitter_#{auth.uid}@example.com"
    
    # パスワード認証用の仕組みを突破するために、仮のランダムパスワードをセット
    temporary_password = SecureRandom.hex(16)
    user.password = temporary_password
    user.password_confirmation = temporary_password
    
    user.level = 1
    user.exp = 0
    
    if user.save
      # 新規登録成功時に、初期ユニット（1, 2, 3）をプレゼントする処理
      default_units = [1, 2, 3].map do |i|
        Myfreet.find_or_create_by(id: i) do |f|
          f.name = "ユニット#{i}"
        end
      end
      default_units.each do |unit|
        UserMyfreet.create(user_id: user.id, myfreet_id: unit.id, level: 1, exp: 0)
      end
    else
      # もし保存に失敗したら、セッションにエラー内容を詰めて新規登録画面に戻す
      session[:error] = "Xアカウントでの登録に失敗しました: #{user.errors.full_messages.join(', ')}"
      redirect '/users/new'
      return
    end
  end
  
  # ログイン状態にしてホーム画面へドン！
  session[:user] = user.id
  redirect '/home'
end

# ======= 👆 ここまで 👆 =======