class RenameVendorColumns < ActiveRecord::Migration[5.2]

  #fix clash with rails foreign key id convention
  def change
    change_table :vendors do |t|
      t.rename :campaign_id, :campaignID
      t.rename :variation_id, :variationID
      t.rename :variant_id, :variantID
    end

    add_column :vendors, :experimentID, :string
  end
end
