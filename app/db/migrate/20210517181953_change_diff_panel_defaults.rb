class ChangeDiffPanelDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column :diffs, :diffPanel, :string, :default => "true"
  end
end
