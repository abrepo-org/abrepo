class AddNewDimOrigDimToDiffs < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :newDim, :json
    add_column :diffs, :origDim, :json
    add_column :diffs, :diffSummary, :string
    add_column :diffs, :is_ignore, :boolean    
  end
end
