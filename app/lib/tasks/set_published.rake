namespace :abrepo do

  task :set_published => :environment do

    # update_all doesn't trigger callbacks, validations but
    # importantly doesn't change updated_at value

    Experiment.all.update_all(published: true)

    Variation.all.update_all(published: true)

  end
end
