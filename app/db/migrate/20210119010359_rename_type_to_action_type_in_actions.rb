class RenameTypeToActionTypeInActions < ActiveRecord::Migration[6.1]
  def change
    rename_column :actions, :type, :actionType
  end
end
