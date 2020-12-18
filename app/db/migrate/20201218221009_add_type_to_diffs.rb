class AddTypeToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :type, :string
  end
end
