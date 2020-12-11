class AddAIdToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :a_id, :string
  end
end
