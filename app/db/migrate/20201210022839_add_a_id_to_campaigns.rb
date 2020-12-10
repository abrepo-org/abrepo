class AddAIdToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :a_id, :string
  end
end
