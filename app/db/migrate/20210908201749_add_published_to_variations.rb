class AddPublishedToVariations < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :published, :boolean, default: false
  end
end
