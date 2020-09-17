class AddFieldsToRenderables < ActiveRecord::Migration[5.2]
  def change
    add_column :renderables, :control, :boolean
    add_reference :renderables, :renderables
  end
end
