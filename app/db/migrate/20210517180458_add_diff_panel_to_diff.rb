class AddDiffPanelToDiff < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :diffPanel, :string
  end
end
