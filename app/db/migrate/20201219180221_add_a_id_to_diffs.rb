class AddAIdToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :a_id, :string
  end
end
