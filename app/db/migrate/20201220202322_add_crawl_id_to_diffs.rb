class AddCrawlIdToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :crawlId, :string
  end
end
