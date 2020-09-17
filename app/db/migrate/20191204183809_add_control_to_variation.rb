class AddControlToVariation < ActiveRecord::Migration[5.2]
  def change
    add_column :variations, :control, :boolean
  end
end
