class AddNumDiffsAvgToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_column :experiments, :numDiffsAvg, :float, default: 0
  end
end
