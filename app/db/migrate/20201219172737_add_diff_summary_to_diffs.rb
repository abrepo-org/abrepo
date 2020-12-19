class AddDiffSummaryToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :diffSummary, :json
  end
end
