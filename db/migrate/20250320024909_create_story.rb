class CreateStory < ActiveRecord::Migration[6.1]
  def change
    create_table :storys do |t|
      t.integer :episode, null: false
      t.integer :step,    null: false
      t.string  :name
      t.text    :text,    null: false
      t.integer :style,   default: 0
    end
  end
end
