require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
# ここから19まで、ローカル環境での実行のため、一時的にコメントに変更、1年後の自分に押しつけ
require 'sinatra'
require 'sinatra/activerecord'

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
set :port, ENV.fetch('PORT', 4567) # 環境変数PORTが存在しない場合は4567をデフォルトに設定
puts "ーーーーーーーーーーーーーVScodeの場合: http://localhost:#{settings.port} ーーーーーーーーーーーーーーーーーーーー"

get '/' do
  erb :index
end

# 新規登録・ログイン関係
get '/users/new' do
    # 新規登録画面を表示する
    erb :sign_up
end
post '/users/new' do
    # 新規登録をする
    # user = Users.create(name: params[:name], mail: params[:mail], password: params[:password], password_confirmation: params[:password_confirmation])
    user = User.create(name: params[:name], mail: params[:mail], password: params[:password], level: 1, exp: 0)
    if user.persisted?
      # ユーザーが正常に保存された場合にユニットを関連付ける
      default_units = [1, 2, 3].map do |i|
        Myfreet.find_or_create_by(id: i) do |f|
          f.name = "ユニット#{i}"
        end
      end
      default_units.each do |unit|
        UserMyfreet.create(user_id: user.id, myfreet_id: unit.id, level: 1, exp: 0)
      end
      session[:user] = user.id
      redirect '/home'
    else
      redirect '/users/new'
    end
end
get '/users/login' do
    # ログイン画面を表示する
    erb :sign_in
end
post '/users/login' do
    # ログインをする
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        redirect '/home'
    else
        redirect '/users/login'
    end
end

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

  # バトル画面へリダイレクト
  redirect '/battle'
end


before do
  session[:index]||= 1
  session[:story]||= 0
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
