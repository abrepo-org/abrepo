class AddAIdToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :a_id, :string
  end
end
