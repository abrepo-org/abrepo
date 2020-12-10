class RenameDiffsToDiffInRenderables < ActiveRecord::Migration[5.2]
  def change
    rename_column :renderables, :diffs, :diff
  end
end
