class RenameCrawlIdToCrawlIdInExperiments < ActiveRecord::Migration[6.1]
  def change
    rename_column :experiments, :crawlID, :crawlId
  end
end
