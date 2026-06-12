class CreateUserItems < ActiveRecord::Migration[6.1]
  def change
    create_table :user_items do |t|
      t.integer :user_id, null: false # どのユーザーが
      t.integer :item_id, null: false # どのアイテムを
      t.integer :count, default: 0, null: false # 何個持っているか

      t.timestamps
    end

    # 💡 重要な add_index の設定
    # 「あるユーザーが、特定のアイテムを1個だけ持っている状態（数量はcountで管理）」を保証するため、
    # user_id と item_id の組み合わせをユニーク（唯一）にします。これで検索も爆速になります！
    add_index :user_items, [:user_id, :item_id], unique: true
  end
end
