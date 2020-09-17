class CreateAudiences < ActiveRecord::Migration[5.2]
  def change
    create_table :audiences do |t|
      t.string :name
      t.string :description
      t.belongs_to :experiment, foreign_key: true

      t.timestamps
    end
  end
end
