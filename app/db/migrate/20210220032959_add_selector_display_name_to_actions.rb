class AddSelectorDisplayNameToActions < ActiveRecord::Migration[6.1]
  def change
    add_column :actions, :selectorDisplayName, :string
  end
end
