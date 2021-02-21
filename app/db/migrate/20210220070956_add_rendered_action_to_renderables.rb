class AddRenderedActionToRenderables < ActiveRecord::Migration[6.1]
  def change
    add_column :renderables, :renderedAction, :json
  end
end
