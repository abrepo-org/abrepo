class RemoveColsFromDiffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :diffs, :diffSummary, :json
    remove_column :diffs, :summarization, :json
    remove_column :diffs, :is_ignore, :boolean
  end
end
