class RemoveBoundingBoxFromDiffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :diffs, :boundingBox, :json
    remove_column :diffs, :change, :string
  end
end
