namespace :abrepo do
  # data migration
  # for profiles change logo_url and favicon_url
  # buckets
  #
  task :update_logo_favicon_url => :environment do

    replacementURL =  'abrepo-production-web-assets'

    Profile.all.each do |profile|


      unless profile.favicon_url.nil?
        profile.favicon_url = profile.favicon_url
                                .sub('abrepo-assets', replacementURL)
      end

      unless profile.logo_url.nil?

        profile.logo_url = profile.logo_url
                             .sub('abrepo-assets', replacementURL)
      end

      if !profile.logo_url.nil? || !profile.favicon_url.nil?
        puts "#{profile.domain}: #{profile.logo_url} | #{profile.favicon_url}"
        profile.save(touch: false) # avoid changing updated_at
      end


    end

  end
end
