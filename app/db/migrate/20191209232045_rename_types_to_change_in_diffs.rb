class RenameTypesToChangeInDiffs < ActiveRecord::Migration[5.2]
  def change
    rename_column :diffs, :type, :changes
  end
end
