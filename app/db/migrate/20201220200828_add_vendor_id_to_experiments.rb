class AddVendorIdToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_column :experiments, :vendor_id, :string
  end
end
