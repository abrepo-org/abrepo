class AddGenDescToExperiment < ActiveRecord::Migration[5.2]
  def change
    add_column :experiments, :gen_desc, :string
  end
end
