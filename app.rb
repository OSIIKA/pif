require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
# ここから19まで、ローカル環境での実行のため、一時的にコメントに変更、1年後の自分に押しつけ
#require 'sinatra'
#require 'sinatra/activerecord'

#configure :production do
  # 本番環境では環境変数DATABASE_URLが設定されている前提
  #set :database, ENV['DATABASE_URL']
#end

#configure :development do
  # ローカル開発ではローカルのPostgreSQLに接続
  #set :database, "postgres://localhost/your_local_db"# your_local_dbの部分は、自分のローカルデータベースの名前に変える必要がある
#end

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
      default_units = [Myfreet.find(1), Myfreet.find(2), Myfreet.find(3)] # ユニット1とユニット2をデフォルトとして関連付け
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
    # 所持艦情報を表示する
    @my_units = session[:my_freets]
    @enemy_units = session[:enemy_freets]
    # デバッグ用ログ
    puts "デバッグ: @my_units => #{@my_units.inspect}"
    puts "デバッグ: @enemy_units => #{@enemy_units.inspect}"
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
texts = [
  "＜紫星・磯秋より、紫星・Userへ、メッセージを送信します。＞",
  "「あなたはもう、こちらに向かっているのでしょうか。宇宙船の中、あるいは情報網の中で、あなたはこの星…紫星に向かってくるでしょう。次の紫星は、何を信じ、どこに向かっていくのでしょうか。自分にはそれを見届ける事は出来ない。そしてあなたの返事も、届くことはないのでしょう。それでも、我々は戦い続けなければなりません。何故ならこの星は…」",
  "＜時間切れになりました。ボイスメッセージを終了します。＞",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「紫星に到着しました。」",
  "宇宙船のドアが開き、あなたは紫星の大地に降り立ちました。",
  "「これが最後と、何度願ったでしょうか。」",
  "そんな独り言を残して、宇宙船は再び発進しました。",
  "ー紫星ー",
  "「君かね、紫星の新しいSQUIDERは。＜変更＞の略である。まぁ、宇宙からの敵など、来るはずがない。楽な役回りと思って、せいぜい楽しみたまえ。…何？過去からのメッセージだと？そんないたずらに向き合う程の暇とは聞いてないぞ。とにかく、正式な手続きはあの建物の中で行われる。詳しい説明は磯秋にでも聞いてくれ。それではこの辺で失礼する。」",
  "ーSQUIDER本部ー",
  "磯秋「ああ、君か。SQUIDERの新しい隊員は。隊長の磯秋だ。今日から君は、新設された「みふさ艦隊」の司令を担当する訳だが、何か質問は…ありそうな顔だな。資料を見てほしい…か。すまないが、少なくとも「この俺ではない」事は確かだ。とにかく今日は拠点を見て回る日だ。」",
  "「今日からあなたの補佐をするロボットです。よろしくお願いいたします。それでは拠点をご案内します。」",
  "",
  "次の日の朝、突然基地のサイレンが鳴り響きます。",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  "「間もなく、紫星に到着します。準備はよろしいですか？」",
  
]

before do
  session[:index]||= 1
  session[:story]||= 0
end

post '/home/story' do
  session[:story] = params[:story].to_i
  if session[:story] == 0
    session[:index] = 1
  elsif session[:story] == 1
    session[:index] = 15
  end
  redirect '/story'
end

get '/story' do
  @story = session[:story]
  if @story == 0
    # @text = texts[session[:index] % 13] # 1～13までの範囲で繰り返し
    if session[:index] >= 1 && session[:index] <= 13
      @text = Story.where(id: session[:index]).first.text
    else
      redirect '/home'
    end
    
  elsif @story == 1
    # @text = texts[(session[:index] % 3) + 14] # 15～17までの範囲で繰り返し
    # @text = Story.where(episode: 1).offset((session[:index] % 3) + 14).limit(1).first.text
    if session[:index] >= 15 && session[:index] <= 17
      @text = Story.where(id: session[:index]).first.text
    else
      redirect '/home'
    end
  else
    @text = "ストーリーモードが選択されていません。"
  end
  session[:index] = (session[:index] + 1)
  erb :story
end

