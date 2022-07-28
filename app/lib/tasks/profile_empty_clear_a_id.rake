namespace :abrepo do
  # data migration
  # for profiles submitted as related_companies they have no
  # experiments - we set a_id to nil.
  #
  # Previously a_id set to datacompany value, which is inconsistent
  #
  task :clear_aid_empty_profiles => :environment do

    Profile.all.includes(:experiments).each do |profile|
      if profile.experiments.empty?
        res = profile.update(a_id: nil)
        puts "#{profile.domain} -> #{res}"
      end
    end

  end
end
