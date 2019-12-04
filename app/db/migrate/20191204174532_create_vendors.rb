class CreateVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :campaign_id
      t.string :variation_id
      t.string :variant_id
      t.belongs_to :experiment, foreign_key: true

      t.timestamps
    end
  end
end
