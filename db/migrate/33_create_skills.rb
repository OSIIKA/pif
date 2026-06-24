class CreateSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :effect_type, null: false
      t.integer :value, default: 0
      t.text :description

      t.timestamps
    end

    # allfreetsテーブルにskill1_id、skill2_id、skill3_id カラムが存在しない場合のみ追加
    unless column_exists?(:allfreets, :skill1_id)
      add_column :allfreets, :skill1_id, :integer
    end
    unless column_exists?(:allfreets, :skill2_id)
      add_column :allfreets, :skill2_id, :integer
    end
    unless column_exists?(:allfreets, :skill3_id)
      add_column :allfreets, :skill3_id, :integer
    end
  end
end
