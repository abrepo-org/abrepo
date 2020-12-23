class AddSummaryNameToVariations < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :summary_name, :string
  end
end
