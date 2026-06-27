class CreateUserItems < ActiveRecord::Migration[6.1]
  def change
    create_table :user_items do |t|
      t.integer :user_id, null: false # どのユーザーが
      t.integer :item_id, null: false # どのアイテムを

      # どの辞書（0?_系列）を参照するか
      # 0: allfreets系列
      # 1: characters系列
      # 2: weapons系列
      # 3: items系列
      t.integer :object_id, default: 0, null: false

      # ① 個数アイテム中間テーブルとしての追加機能
      t.integer :count, default: 0, null: false # 何個持っているか
      # ② 艦・キャラ・武装中間テーブルとしての機能
      t.integer :level, default: 1, null: false # アイテムのレベル（強化度合い）
      t.integer :exp, default: 0, null: false # アイテムの経験値（強化度合い）
      # ③ 艦中間テーブルとしての機能
      # スキルを持つ装備への参照は、weapon_skillsテーブルを通じて行う
      t.integer :weapon_id
      # スキルを持つキャラクターへの参照は、character_skillsテーブルを通じて行う
      t.integer :character_id
      # ④ 念の為の timestamps
      t.timestamps
    end

    # 💡 重要な add_index の設定（無効化）
    # 「あるユーザーが、特定のアイテムを1個だけ持っている状態（数量はcountで管理）」を保証するため、
    # user_id と item_id の組み合わせをユニーク（唯一）にします。これで検索も爆速になります！
    # add_index :user_items, [:user_id, :item_id], unique: true
  end
end
