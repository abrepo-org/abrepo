class CreateDiffs < ActiveRecord::Migration[5.2]
  def change
    create_table :diffs do |t|
      t.string :type
      t.string :selector
      t.boolean :visible
      t.json :boundingBox
      t.json :calculated
      t.belongs_to :renderable, foreign_key: true

      t.timestamps
    end
  end
end
