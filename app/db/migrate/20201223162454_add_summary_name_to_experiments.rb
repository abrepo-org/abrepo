class AddSummaryNameToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_column :experiments, :summary_name, :string
  end
end
