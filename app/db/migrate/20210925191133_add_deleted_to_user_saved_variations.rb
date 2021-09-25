class AddDeletedToUserSavedVariations < ActiveRecord::Migration[6.1]
  def change
    add_column :user_saved_variations, :deleted, :boolean, default: false
  end
end
