class RemoveForeignKeysFromAction < ActiveRecord::Migration[5.2]
  def change
    remove_reference :actions, :variation, foreign_key: true
    remove_reference :actions, :renderable, foreign_key: true
  end
end
