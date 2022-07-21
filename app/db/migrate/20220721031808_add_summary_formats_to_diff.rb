class AddSummaryFormatsToDiff < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :summary_added_format, :string
    add_column :diffs, :summary_removed_format, :string
  end
end
