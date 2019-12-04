class AddUrlToVariation < ActiveRecord::Migration[5.2]
  def change
    add_column :variations, :url, :string
  end
end
