class RenameChangesToChangeInDiffs < ActiveRecord::Migration[5.2]
  def change
    rename_column :diffs, :changes, :change
  end
end
