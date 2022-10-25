namespace :abrepo do

  desc "Build, filter, subsume list of related companies - cluster of partners/competitors"

  task :get_related_companies => :environment do
    NUM = 100
    companies = {}

    Profile.includes(:experiments)
      .where.not(experiments: {profile_id: nil})
      .each do |profile|

        next if profile.active_related_companies(NUM).length == 0

        domain = profile.domain

        related = profile
                    .active_related_companies(NUM)
                    .distinct
                    .pluck(:domain)

        companies[domain] = related
    end

    #filter empties, dupes
    filtered = []
    companies.keys.each do |company|

        related = companies[company]
        next if related.nil?

        all = (related + [company]).uniq
        next if all.length == 1

        filtered.push(all)
    end


    #subsume
    subsumed = []
    for elem in filtered do
      next if filtered.any?{ |s| (elem - s).length == 0 && s != elem}
      subsumed.push(elem)
    end

    # output want easy export csv via space delimited
    subsumed.each do |s|
      puts s.join(" ")
    end

  end



  desc "Build list of domains by industry"

  task :get_industry_companies => :environment do

    collects = []

    # get industry -> domains
    ActsAsTaggableOn::Tag
      .for_context("industry_tag")
      .includes(taggings: :taggable).each do |tag|

      profile_ids = tag.taggings.pluck(:taggable_id)
      domains = Profile
                  .includes(:experiments)
                  .where.not(experiments: {profile_id: nil})
                  .where(id: profile_ids)
                  .distinct
                  .pluck(:domain)

      list = ([tag.name] + domains).uniq

      collects.push( list )

    end

    collects.each do |c|
      puts c.join(" ")
    end
  end

end
