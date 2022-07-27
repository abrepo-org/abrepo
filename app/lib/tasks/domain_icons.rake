namespace :abrepo do


  task :copy_domain_icons => :environment do

    puts Rails.root
    f = File.open("#{Rails.root}/lib/tasks/domain-icons.json")
    domain_icons = f.read()
    json = JSON.parse(domain_icons)

    json.each do |record|

      puts record["domain"]
      profile = Profile.find_by_domain(record["domain"])
      res = profile.update(favicon_url: record["favicon_url"], logo_url: record["logo_url"]) if profile
      puts res

    end
  end
end
