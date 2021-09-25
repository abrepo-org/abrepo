class CreateUserSavedVariations < ActiveRecord::Migration[6.1]
  def change
    create_table :user_saved_variations do |t|
      t.belongs_to :user
      t.belongs_to :variation      
      t.timestamps
    end
  end
end
