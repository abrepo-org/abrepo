class RemoveVisibleFromDiffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :diffs, :visible, :boolean
  end
end
