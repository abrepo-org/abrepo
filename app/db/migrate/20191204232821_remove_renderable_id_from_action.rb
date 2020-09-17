class RemoveRenderableIdFromAction < ActiveRecord::Migration[5.2]
  def change
    remove_column :actions, :renderable_id, :bigint
  end
end
