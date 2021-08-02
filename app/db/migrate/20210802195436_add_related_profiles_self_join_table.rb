class AddRelatedProfilesSelfJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_table :related_profiles do |t|
      t.integer :profile_id
      t.integer :related_profile_id      
    end

    add_index(:related_profiles, [:profile_id, :related_profile_id], :unique => true)
    add_index(:related_profiles, [:related_profile_id, :profile_id], :unique => true)
  end
end
