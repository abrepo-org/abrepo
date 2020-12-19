class RemoveDiffSummaryFromDiffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :diffs, :diffSummary, :string
  end
end
