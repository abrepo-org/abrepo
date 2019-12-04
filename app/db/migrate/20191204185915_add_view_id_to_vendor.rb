class AddViewIdToVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :viewID, :string
  end
end
