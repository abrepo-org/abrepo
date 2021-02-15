class AddUrlToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :url, :string
  end
end
