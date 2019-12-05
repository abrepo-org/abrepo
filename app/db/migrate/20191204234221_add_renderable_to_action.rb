class AddRenderableToAction < ActiveRecord::Migration[5.2]
  def change
    add_reference :actions, :renderable, foreign_key: true
  end
end
