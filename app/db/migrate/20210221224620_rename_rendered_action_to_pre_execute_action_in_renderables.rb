class RenameRenderedActionToPreExecuteActionInRenderables < ActiveRecord::Migration[6.1]
  def change
    rename_column :renderables, :renderedAction, :preExecuteAction
  end
end
