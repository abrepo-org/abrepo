class AddSelectorDisplayNameToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :selectorDisplayName, :string
  end
end
