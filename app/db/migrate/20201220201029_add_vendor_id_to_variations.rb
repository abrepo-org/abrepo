class AddVendorIdToVariations < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :vendor_id, :string
  end
end
