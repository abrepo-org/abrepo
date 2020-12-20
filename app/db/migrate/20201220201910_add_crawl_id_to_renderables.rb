class AddCrawlIdToRenderables < ActiveRecord::Migration[6.1]
  def change
    add_column :renderables, :crawlId, :string
  end
end
