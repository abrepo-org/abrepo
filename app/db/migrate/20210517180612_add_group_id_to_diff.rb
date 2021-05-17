class AddGroupIdToDiff < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :group_id, :string
  end
end
