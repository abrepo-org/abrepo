class AddPublishedToExperiments < ActiveRecord::Migration[6.1]
  def change
    add_column :experiments, :published, :boolean, default: false
  end
end
