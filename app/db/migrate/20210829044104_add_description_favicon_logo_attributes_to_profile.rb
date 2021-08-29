class AddDescriptionFaviconLogoAttributesToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :description, :string
    add_column :profiles, :favicon_url, :string
    add_column :profiles, :logo_url, :string
  end
end
