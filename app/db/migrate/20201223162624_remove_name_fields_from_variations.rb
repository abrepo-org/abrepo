class RemoveNameFieldsFromVariations < ActiveRecord::Migration[6.1]
  def change
    remove_column :variations, :variationSummary, :string
    remove_column :variations, :gen_desc, :string
    remove_column :variations, :name, :string
  end
end
