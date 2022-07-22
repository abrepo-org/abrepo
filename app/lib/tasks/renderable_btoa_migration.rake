namespace :abrepo do

  desc "Data migrations to replace domains (adblocked) from s3 urls with url-safe base64 string"

  task :renderable_screenshotFilename => :environment do

    Renderable.select(:id, :domain, :screenshotFilename).each do |renderable|
      domain = renderable.domain
      base64domain = Base64.urlsafe_encode64(domain, padding:false)

      uri = renderable.screenshotFilename.sub(domain, base64domain)
      Renderable.update(renderable.id, screenshotFilename: uri)
      puts "#{domain} -> #{uri}"
    end

  end



  task :profile_favicon_logo_urls => :environment do

    #abrepo-assets
    Profile.select(:id, :domain, :favicon_url, :logo_url).each do |profile|
      domain = profile.domain
      base64domain = Base64.urlsafe_encode64(domain, padding:false)

      favicon_uri = nil
      logo_uri = nil

      if profile.favicon_url && profile.favicon_url.include?("abrepo-assets")
        favicon_uri = profile.favicon_url.sub(domain, base64domain)
        Profile.update(profile.id, favicon_url: favicon_uri)
        puts "#{profile.favicon_url} -> #{favicon_uri}"
      end

      if profile.logo_url && profile.logo_url.include?("abrepo-assets")
        logo_uri = profile.logo_url.sub(domain, base64domain)
        Profile.update(profile.id, logo_url: favicon_uri)
        puts "#{profile.logo_url} -> #{logo_uri}"
      end

    end

  end

end
