class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.string :domain
      t.string :company_name

      t.timestamps
    end
  end
end
