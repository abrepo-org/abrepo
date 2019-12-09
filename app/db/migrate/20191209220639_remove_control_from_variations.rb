class RemoveControlFromVariations < ActiveRecord::Migration[5.2]
  def change
    remove_column :variations, :control, :boolean
  end
end
