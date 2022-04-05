namespace :abrepo do
  desc "Data migration Audience to experiment.audience_name"
  # we know experiment.audience_name
  # we don't know shifted variation.audience_name, since they override
  # these unfortunately have to be resubmitted

  task :migrate_audience_name => :environment do
    experiments = Experiment.all
    experiments.each do |e|
      unless e.audience.name.blank?
        e.audience_name = e.audience.name
        e.save
        puts e.audience.name
      end
    end
  end
end
