class AddExperimentSummaryToExperiments < ActiveRecord::Migration[5.2]
  def change
    add_column :experiments, :experimentSummary, :string
    add_column :experiments, :a_id, :string
  end
end
