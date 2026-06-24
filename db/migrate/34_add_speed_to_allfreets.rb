class AddSpeedToAllfreets < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:allfreets, :speed)
      add_column :allfreets, :speed, :integer
    end
  end
end
