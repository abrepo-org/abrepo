class ChangeRenameTypeToDiffTypeInDiffs < ActiveRecord::Migration[6.1]
  def change
    rename_column :diffs, :type, :diffType
  end
end
