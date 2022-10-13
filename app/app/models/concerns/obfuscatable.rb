#
# Obfuscate Policy
#
#
# Two basic triggers:
# 1. number of expvar in result set
# 2. number of variation#show page views
#
#
# Accounts:
#
# * admin / moderator / subscriber : no obfuscation
# * account no subscription: currently same as random
# * random visitor:
#
# home#index:          obfuscate_from: all results after 2nd page
#
# profile#show:        obfuscate_from:  after max 5 expvars (config.num_obfuscate)
#                      or 1/2 length of set (application_controller.rb: num_given_pagination)
#
# search#index:        obfuscate_from: after 5 expvars (config.num_obfuscate)
#                      or 1/2 length of set (application_controller.rb: num_given_pagination)
#
# variation#show:      obfuscate after 7 (various) variation#show page visits
#                      (config.max_visits_variation_show)
#

module Obfuscatable
  extend ActiveSupport::Concern

  included do
    class_attribute :obfuscated_attrs
    attribute :obfuscated, :boolean, default: false
  end

  module ClassMethods

    #
    # example when include Obfuscatble
    # 'obfuscatable attributes: [:summary_name, :domain]'
    # method obfuscatble, which passes options[:attributes] array
    #

    def obfuscatable(options)
      self.obfuscated_attrs = options[:attributes]
    end
  end

  # replace displayed string with random chars, except whitespace
  # check for :dependent instance to make sure
  # NB: this checks against the in-memory dependency
  # (a freshly query will never be obfuscated)
  def obfuscate(force = false)
    self.readonly!

    self.obfuscated_attrs.each do |attr|
      self[attr] = obfuscate_text(self[attr]) unless self[attr].blank?
    end

    self[:obfuscated] = true

    self
  end

  def obfuscate_text(text)
       text.chars
         .map{ |c| c.ord == 32 ? c : (rand(26) + 97).chr  }
         .join()
  end
end
