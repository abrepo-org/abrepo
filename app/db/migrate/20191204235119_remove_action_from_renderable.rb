class RemoveActionFromRenderable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :renderables, :action, foreign_key: true
  end
end
