class DropVendorModel < ActiveRecord::Migration[6.1]
  def change
    drop_table :vendors
  end
end
