class CreateRenderables < ActiveRecord::Migration[5.2]
  def change
    create_table :renderables do |t|
      t.string :screenshotFilename
      t.string :renderedURL
      t.string :renderedTitle
      t.string :domain

      t.timestamps
    end
  end
end
