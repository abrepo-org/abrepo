class AddViewModeToDiff < ActiveRecord::Migration[6.1]
  def change
    add_column :diffs, :viewMode, :string
  end
end
