class RemoveNameFieldsFromExperiments < ActiveRecord::Migration[6.1]
  def change
    remove_column :experiments, :experimentSummary, :string
    remove_column :experiments, :gen_desc, :string
    remove_column :experiments, :name, :string
  end
end
