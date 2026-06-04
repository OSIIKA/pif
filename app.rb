require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
# ここから19まで、ローカル環境での実行のため、一時的にコメントに変更、1年後の自分に押しつけ
require 'sinatra'
require 'sinatra/activerecord'
Dir.glob('./app/models/*.rb').each { |file| require file }
require 'omniauth'
require 'omniauth-google-oauth2'
require 'omniauth/twitter2'

set :public_folder, 'public'
set :views, 'views'

#configure :production do
  # 本番環境では環境変数DATABASE_URLが設定されている前提
  #set :database, ENV['DATABASE_URL']
#end

configure :development do
  # ローカル開発ではローカルのPostgreSQLに接続
  set :database, "postgres://postgres:YAMATO2199@localhost:5433/pif_development"# 自分のローカルデータベースの名前に変更完了
end

# 以下、Sinatra のルーティングやモデル定義

# セッション機能
enable :sessions
# 環境変数から鍵を取得し、無ければ開発用の仮の鍵を使う
set :session_secret, ENV.fetch('SESSION_SECRET', 'this_is_a_secret_key_for_development_only_12345')
set :port, ENV.fetch('PORT', 4567) # 環境変数PORTが存在しない場合は4567をデフォルトに設定
puts "ーーーーーーーーーーーーーVScodeの場合: http://localhost:#{settings.port} ーーーーーーーーーーーーーーーーーーーー"

# OmniAuthミドルウェアの設定を追加
OmniAuth.config.allowed_request_methods = [:post, :get] # 👈 この行を追加！
use OmniAuth::Builder do
  # ⚠️ 鍵（IDとシークレット）はセキュリティのため環境変数から読み込みます
  
  # Googleログインの設定
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'email, profile' # ユーザーのメールアドレスとプロフィールを取得する設定
  }

  # X（Twitter）ログインの設定
  provider :twitter2, ENV['TWITTER_CLIENT_ID'], ENV['TWITTER_CLIENT_SECRET'], {
    scope: 'users.read tweet.read' # ユーザー情報を読み取る最小限の権限
  }
end

# 共通で使えるメソッド（ヘルパー）を定義
helpers do
  # 現在ログインしているユーザー情報を取得
  def current_user
    @current_user ||= User.find_by(id: session[:user]) if session[:user]
  end

  # ログインしていなければログイン画面に強制送還
  def authenticate!
    redirect '/users/login' unless current_user
  end
end

# ログイン・新規登録・トップページ以外のすべてのアクセスで、自動的に関所を通す
before do
  session[:index]||= 1
  session[:story]||= 0
  # パスが以下に一致する場合「以外」は、すべてログインチェックを実行
  unless request.path_info == '/' || 
         request.path_info.start_with?('/users/new') || 
         request.path_info.start_with?('/users/login') ||
         request.path_info.start_with?('/auth/')
    authenticate!
  end
end

get '/' do
  erb :index
end

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
    end
    
    erb :home
end

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

post '/home/levelup' do
  unit_id = params[:unit_id] # レベルアップ対象のユニットID
  user_myfreet = UserMyfreet.find(unit_id) # 対象ユニットを取得
  # バグり散らかしている現場（今はそれどころでは無い）
  # EXPが100以上でレベルアップ可能か確認
  if user_myfreet.exp >= 100
    user_myfreet.update(level: user_myfreet.level + 1, exp: user_myfreet.exp - 100)
    @message = "#{user_myfreet.myfreet.name}のレベルが#{user_myfreet.level}にアップしました！"
  else
    @message = "EXPが不足しています！レベルアップには100EXPが必要です。"
  end

  erb :home
end

post '/home/freet' do
  Myfreet.create(name: params[:name], hp: params[:hp], atk: params[:atk], info: params[:info])
  redirect '/home'
end

post '/home/battle' do
  session[:story] = params[:story].to_i
  # データベースの値をセッションに保存
  if session[:story] == 0
    session[:enemy_freets] = Enemyfreet.where(id: [1, 2, 3]).as_json
  elsif session[:story] == 1
    session[:enemy_freets] = Enemyfreet.where(id: [4, 5, 6]).as_json
  end
  # バトル画面に移動する
  redirect '/battle'
end

# バトル画面関係
get '/battle' do
  stage = session[:battle_stage]
  # 味方ロード（ユーザーの所持艦）
  if session[:my_freets].nil?
    user_myfreets = UserMyfreet.where(user_id: session[:user])
    session[:my_freets] = user_myfreets.map(&:as_json)
  end
  @my_units = session[:my_freets]
  # 敵ロード（stage に応じて複数体）
  if session[:enemy_freets].nil?
    enemies = Enemyfreet.where(stage: stage)
    session[:enemy_freets] = enemies.map(&:as_json)
  end
  @enemy_units = session[:enemy_freets]
  # デバッグ用ログ
  puts "デバッグ: @my_units => #{@my_units.inspect}"
  puts "デバッグ: @enemy_units => #{@enemy_units.inspect}"
  # 勝敗判定
  if @my_units.all? { |unit| unit['myfreet']['hp'] <= 0 }
    redirect '/battle/lost'
  elsif @enemy_units.all? { |unit| unit['hp'] <= 0 }
    redirect '/battle/won'
  end
  # バトル画面を表示する
  erb :battle
end

get '/battle/lost' do
  @finaresult="敗北"
  erb :result
end
get '/battle/won' do
  @my_units = session[:my_freets]
  @enemy_units = session[:enemy_freets]
  @finaresult="勝利"
  # 現在のユーザーに関連する全てのUserMyfreetを取得
  user_myfreets = UserMyfreet.where(user_id: session[:user])
  # 各UserMyfreetに対してレベルを1増加
  user_myfreets.each do |user_myfreet|
    user_myfreet.update(exp: user_myfreet.exp + 100)
  end
  user_exp = User.where(id: session[:user])
  user_exp.each do |user_exp|
    user_exp.update(exp: user_exp.exp + 100)
  end
  erb :result
end

#バトル画面で自分のキャラと相手のキャラを選択して攻撃を実行する際に行う処理
post '/battle/attack' do
  # 攻撃と被攻撃のユニットをセッションから取得
  @my_units = session[:my_freets]
  @enemy_units = session[:enemy_freets]

  # 攻撃ユニットと被攻撃ユニットを特定
  attacker = @my_units.find { |unit| unit['myfreet']["id"] == params[:my_unit_id].to_i }
  defender = @enemy_units.find { |unit| unit["id"] == params[:enemy_unit_id].to_i }

  # 攻撃処理
  defender["hp"] -= attacker['myfreet']["atk"]
  defender["hp"] = [defender["hp"], 0].max # HPが0未満にならないよう制御

  # 更新されたデータをセッションに保存
  session[:my_freets] = @my_units
  session[:enemy_freets] = @enemy_units
  session[:last_attack] = {
    attacker: attacker['myfreet']["id"],
    defender: defender["id"],
    damage: attacker['myfreet']["atk"]
  }
  # バトル画面へリダイレクト
  redirect '/battle'
end

post '/home/story' do
  session[:episode] = params[:story].to_i
  session[:step] = 1

  # ★ログ初期化（ここが重要）
  session[:log] = []

  redirect '/story'
end

get '/story' do
  episode = session[:episode]
  step = session[:step]

  story_data = Story.where(episode: episode, step: step).first

  # ストーリーが終わったらホームへ
  if story_data.nil?
    redirect '/home'
  end

  # ★ battle が 0 でない場合 → 戦闘へ遷移
  if story_data.battle != 0
    # 戦闘ステージ番号を保存
    session[:battle_stage] = story_data.battle

    # 次の step に進めてから戦闘へ
    session[:step] += 1

    redirect '/battle'
  end

  # ★ 通常の会話処理
  @name = story_data.name
  @text = story_data.text

  # ログ保存
  session[:log] ||= []
  session[:log] << { name: @name, text: @text }

  # 次の step へ
  session[:step] += 1

  erb :story
end
get '/story/skip' do
  episode = session[:episode]

  # このエピソードの最大 step を取得
  last_step = Story.where(episode: episode).maximum(:step)

  # 次に読み込む step を「最終 step + 1」にする
  session[:step] = last_step + 1

  # story に飛ばす → 自動的に「次のステップが無い → /home」に戻る
  redirect '/story'
end
post '/story/auto' do
  session[:auto] = params[:auto] == "on"
  redirect '/story'
end

# 利用規約ページ
get '/terms' do
  erb :terms
end

# プライバシーポリシーページ
get '/privacy' do
  erb :privacy
end