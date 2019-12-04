class CreateActions < ActiveRecord::Migration[5.2]
  def change
    create_table :actions do |t|
      t.string :type
      t.string :url
      t.string :selector
      t.integer :waitfor
      t.belongs_to :variation, foreign_key: true
      t.belongs_to :renderable, foreign_key: true

      t.timestamps
    end
  end
end
