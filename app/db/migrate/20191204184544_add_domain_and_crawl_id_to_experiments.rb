class AddDomainAndCrawlIdToExperiments < ActiveRecord::Migration[5.2]
  def change
    add_column :experiments, :domain, :string
    add_column :experiments, :crawlID, :string
  end
end
