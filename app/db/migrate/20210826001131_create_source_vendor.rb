class CreateSourceVendor < ActiveRecord::Migration[6.1]
  def change
    create_table :source_vendors do |t|
      t.string :name

      t.timestamps
    end
  end
end
