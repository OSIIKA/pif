class CreateUsersteps < ActiveRecord::Migration[6.1]
  def change
    create_table :usersteps do |t|
      t.integer :user_id, null: false # どのユーザーのステップか
      t.integer :limited_gacha_step, :integer, default: 1 # 現在のステップ（例: 1, 2, 3 ...）

    end

    # よく検索する項目にはインデックスを貼ると爆速になります
    add_index :usersteps, :user_id
  end
end
