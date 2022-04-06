class DropAudienceTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :audiences
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
