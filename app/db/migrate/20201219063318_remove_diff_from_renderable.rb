class RemoveDiffFromRenderable < ActiveRecord::Migration[6.1]
  def change
    remove_column :renderables, :diff, :json
  end
end
