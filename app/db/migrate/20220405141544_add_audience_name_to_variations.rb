class AddAudienceNameToVariations < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :audience_name, :string
  end
end
