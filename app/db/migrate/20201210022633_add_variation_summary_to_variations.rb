class AddVariationSummaryToVariations < ActiveRecord::Migration[5.2]
  def change
    add_column :variations, :variationSummary, :string
    add_column :variations, :a_id, :string
  end
end
