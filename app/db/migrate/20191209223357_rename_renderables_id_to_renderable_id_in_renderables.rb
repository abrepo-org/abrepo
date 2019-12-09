class RenameRenderablesIdToRenderableIdInRenderables < ActiveRecord::Migration[5.2]
  def change
    rename_column :renderables, :renderables_id, :renderable_id
  end
end
