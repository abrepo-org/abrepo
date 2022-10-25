class SitemapController < ApplicationController

  def index
    # single urls - coded in index.xml.erb

    # landing#index
    # tags
    # industries
    # search
    # legals

    #profiles
    @profiles = Profile
                  .includes(:experiments)
                  .where.not(company_name: nil)
                  .where.not(experiments: {profile_id: nil})
                  .where(experiments: {published: true})
                  .select(:id, :company_name, :updated_at)
                  .distinct

    #profiles page N
    @pagy, profiles = pagy(@profiles, items: 20)

    # variations
    @variations = Variation
                    .where.not(summary_name: nil)
                    .where(published: true)
                    .select(:id, :summary_name, :updated_at)

  end
end
