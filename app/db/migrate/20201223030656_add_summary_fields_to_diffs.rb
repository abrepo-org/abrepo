class AddSummaryFieldsToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :summary_delta, :string
    add_column :diffs, :summary_added, :string
    add_column :diffs, :summary_removed, :string
  end
end
