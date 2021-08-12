class AddExperimentIdToPgSearchDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :pg_search_documents, :experiment_id, :bigint
    add_index :pg_search_documents, :experiment_id
  end
end
