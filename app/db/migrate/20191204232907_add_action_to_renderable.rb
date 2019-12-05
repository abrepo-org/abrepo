class AddActionToRenderable < ActiveRecord::Migration[5.2]
  def change
    add_reference :renderables, :action, foreign_key: true
  end
end
