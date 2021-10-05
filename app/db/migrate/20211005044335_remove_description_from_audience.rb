class RemoveDescriptionFromAudience < ActiveRecord::Migration[6.1]
  def change
    remove_column :audiences, :description, :string
  end
end








