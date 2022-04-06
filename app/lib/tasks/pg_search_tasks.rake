namespace :abrepo do

  desc "Data migrations to remove modify records/index related to pg_search multisearch"

  task :pg_search_multisearch_remove_audience_data => :environment do
    PgSearch::Document.delete_by(searchable_type: "Audience")
  end

end
