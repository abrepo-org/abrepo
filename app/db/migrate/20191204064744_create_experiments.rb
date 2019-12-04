class CreateExperiments < ActiveRecord::Migration[5.2]
  def change
    create_table :experiments do |t|
      t.string :name
      t.belongs_to :profile, foreign_key: true

      t.timestamps
    end
  end
end
