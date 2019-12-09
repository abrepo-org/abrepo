class AddCrawlIdToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :crawlID, :string
  end
end
