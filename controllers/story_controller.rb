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