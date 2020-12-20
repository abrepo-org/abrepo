class RenameCrawlIdToCrawlIdInActions < ActiveRecord::Migration[6.1]
  def change
    rename_column :actions, :crawlID, :crawlId
  end
end
