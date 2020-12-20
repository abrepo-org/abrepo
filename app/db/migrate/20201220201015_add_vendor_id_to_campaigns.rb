class AddVendorIdToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :vendor_id, :string
  end
end
