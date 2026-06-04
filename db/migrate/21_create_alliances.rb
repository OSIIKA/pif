class CreateAlliances < ActiveRecord::Migration[6.1]
  def change
    create_table :alliances do |t|
      t.string :join_type, default: 'public', null: false
      t.string :name, null: false
      t.integer :leader_id, null: false
      t.text :description
      t.integer :level, default: 1, null: false
      t.integer :exp, default: 0, null: false
      t.text :notice # 同盟の告知内容
      t.timestamps
    end

    # 同じ名前の同盟が作られないようにロックをかける
    add_index :alliances, :name, unique: true
    # 盟主のIDで検索を早くするためのインデックス
    add_index :alliances, :leader_id
  end
end
