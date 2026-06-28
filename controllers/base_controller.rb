# 📄 controllers/base_controller.rb
# ===========================
# 📚基地画面GET
# ===========================
get '/base' do
  # 👤 ログインユーザーの取得
  @user = User.find_by(id: session[:user])
  redirect '/users/login' if @user.nil?

  # 🏢 ユーザーの基地データを取得（なければ初期状態で作成）
  @user_base = @user.user_base || @user.create_user_base

  # 👥 現在スロット（1〜4）に配置されているキャラクターの情報を Item から取得
  @slotted_chars = {
    1 => @user.user_items.find_by(id: @user_base.slotted_character_1_id),
    2 => @user.user_items.find_by(id: @user_base.slotted_character_2_id),
    3 => @user.user_items.find_by(id: @user_base.slotted_character_3_id),
    4 => @user.user_items.find_by(id: @user_base.slotted_character_4_id)
  }

  # 倉庫にあるキャラ（UserItem.object_id = 1）
  @available_characters = @user.user_items.where(object_id: 1)

  # 🔍 🟢 ここを追記：大倉さん提案の「特定キャラによる機能解放システム」
  # 今回は「北上湊」がスロットのどこかに配置されているかをチェックします
  # （もし「倉庫にいるだけでOK」にしたい場合は、@available_characters.any? を使います）
  @has_kitakami = @slotted_chars.values.compact.any? { |char| char.name.include?("北上湊") }

  # 🟢 ここまで追記

  # 🏁 最後に基地画面のERBを呼び出す
  erb :base
end

# 🛠️ キャラクター配置を実行する機能（大倉さん専用の格納機能）
post '/base/set_character' do
  @user = User.find_by(id: session[:user])
  redirect '/users/login' if @user.nil?
  
  slot_num = params[:slot_num].to_i
  user_item_id = params[:user_item_id].to_i

  user_item = @user.user_items.find_by(id: user_item_id)

  if user_item && user_item.object_id == 1
    @user.user_base.update("slotted_character_#{slot_num}_id": user_item.id)
  end

  # ✨ 配置が終わったら、何事もなかったかのように基地画面にリダイレクト！
  redirect '/base'
end