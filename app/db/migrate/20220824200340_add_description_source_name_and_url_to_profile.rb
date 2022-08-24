class AddDescriptionSourceNameAndUrlToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :description_source_name, :string
    add_column :profiles, :description_source_url, :string
  end
end
