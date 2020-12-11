class AddSummarizationToDiffs < ActiveRecord::Migration[5.2]
  def change
    add_column :diffs, :summarization, :json
  end
end
