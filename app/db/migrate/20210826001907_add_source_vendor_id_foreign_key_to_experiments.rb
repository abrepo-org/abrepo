class AddSourceVendorIdForeignKeyToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_reference :experiments, :source_vendor, foreign_key: true
  end
end
