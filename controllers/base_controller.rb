# 📄 controllers/base_controller.rb

# 🏢 基地画面の表示
get '/base' do
  # 👤 ログインユーザーの取得
  @user = User.find_by(id: session[:user_id])
  redirect '/login' unless @user

  # 🏢 ユーザーの基地データを取得（なければ初期状態で作成）
  @user_base = @user.user_base || @user.create_user_base

  # 👥 現在スロット（1〜4）に配置されているキャラクターの情報を Item から取得
  @slotted_chars = {
    1 => Item.find_by(type: 4, each_id: @user_base.slotted_character_1_id),
    2 => Item.find_by(type: 4, each_id: @user_base.slotted_character_2_id),
    3 => Item.find_by(type: 4, DB_each_id: @user_base.slotted_character_3_id),
    4 => Item.find_by(type: 4, each_id: @user_base.slotted_character_4_id)
  }

  # 📦 倉庫から「ユーザーが所持している基地キャラ（type: 4）」をすべて取得
  # user_items から type: 4 の items をINNER JOINで引っ張ってきます
  @available_characters = Item.where(type: 4).joins(:user_items).where(user_items: { user_id: @user.id })

  erb :base
end

# 🛠️ キャラクター配置を実行する機能（大倉さん専用の格納機能）
post '/base/set_character' do
  @user = User.find_by(id: session[:user_id])
  redirect '/login' unless @user
  
  user_base = @user.user_base || @user.create_user_base

  # 📥 画面のフォームから「どのスロット(1〜4)に」「どのキャラ(each_id)」を入れるか受け取る
  slot_num = params[:slot_num].to_i
  chosen_each_id = params[:each_id].present? ? params[:each_id].to_i : nil

  # 🔄 指定されたスロットのデータを書き換える
  case slot_num
  when 1 then user_base.update(slotted_character_1_id: chosen_each_id)
  when 2 then user_base.update(slotted_character_2_id: chosen_each_id)
  when 3 then user_base.update(slotted_character_3_id: chosen_each_id)
  when 4 then user_base.update(slotted_character_4_id: chosen_each_id)
  end

  # ✨ 配置が終わったら、何事もなかったかのように基地画面にリダイレクト！
  redirect '/base'
end