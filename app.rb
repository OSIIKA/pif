require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
# ここから19まで、ローカル環境での実行のため、一時的にコメントに変更、1年後の自分に押しつけ
require 'sinatra'
require 'sinatra/activerecord'
Dir.glob(File.expand_path('../app/models/*.rb', __FILE__)).each do |file|
  require file
end
require 'omniauth'
require 'omniauth-google-oauth2'
require 'omniauth/twitter2'
# 💡 「app.rbがあるフォルダ」を基準に、コントローラーをすべて一括で読み込む
Dir.glob(File.expand_path('../controllers/*_controller.rb', __FILE__)).each do |file|
  require file
end

set :public_folder, 'public'
set :views, 'views'

#configure :production do
  # 本番環境では環境変数DATABASE_URLが設定されている前提
  #set :database, ENV['DATABASE_URL']
#end
# 🚀 今日（仮のリリース日）を定義
RELEASE_DATE = Date.parse("2026-06-13")
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
  # 🔴 進化した汎用赤ポチ判定メソッド（調べたい種類をシンボルで受け取る）
  # 使い方例： show_badge?(:alliance_request) や show_badge?(:new_event)
  def show_badge?(type)
    current_user = User.find_by(id: session[:user])
    return false if current_user.nil?

    case type
    # ---------------------------------------------------------
    # ① 同盟の加入申請（盟主・副盟主のみ、一度見たら消える）
    # ---------------------------------------------------------
    when :alliance_request
      return false if current_user.alliance_role < 3
      # 現在のリアルタイムな申請者数をカウント
      current_count = User.where(alliance_id: current_user.alliance_id, alliance_role: 1).count
      # 申請者が1人以上いて、かつ「最後に見た時の人数」とズレていれば赤ポチを出す！
      current_count > 0 && current_count != session[:last_checked_request_count].to_i

    # ---------------------------------------------------------
    # ② 同盟告知の変更（全メンバー対象、一度見たら消える）※将来用
    # ---------------------------------------------------------
    when :alliance_notice
      # 将来、告知が更新されたら session[:seen_alliance_notice] を消すようにして、
      # ここで「まだ見ていなければ true」にする、といった柔軟な追加がいつでも可能！
      !session[:seen_alliance_notice]

    # ---------------------------------------------------------
    # ③ 全体イベントの公開（全員対象）※将来用
    # ---------------------------------------------------------
    when :new_event
      # ここにイベント用の条件をいつでも生やせます
      false

    else
      false
    end
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