class AddVariationToVendor < ActiveRecord::Migration[5.2]
  def change
    add_reference :vendors, :variation, foreign_key: true
  end
end
