class AddDiffsAidToRenderables < ActiveRecord::Migration[5.2]
  def change
    add_column :renderables, :diffs, :json
    add_column :renderables, :a_id, :string
  end
end
