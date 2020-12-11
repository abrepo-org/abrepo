class AddGenDescToVariation < ActiveRecord::Migration[5.2]
  def change
    add_column :variations, :gen_desc, :string
  end
end
