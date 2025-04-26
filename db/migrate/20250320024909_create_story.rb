class CreateStory < ActiveRecord::Migration[6.1]
  def change
    create_table :storys do |t|
      t.string :name
      t.integer :episode
      t.string :text
    end
  end
end
