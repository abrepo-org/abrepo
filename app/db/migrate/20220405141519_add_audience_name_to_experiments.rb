class AddAudienceNameToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_column :experiments, :audience_name, :string
  end
end
