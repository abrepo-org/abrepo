class AddScreenshotDimensionsToRenderable < ActiveRecord::Migration[6.1]
  def change
    add_column :renderables, :screenshotWidth, :integer
    add_column :renderables, :screenshotHeight, :integer
  end
end
