module Obfuscatable
  extend ActiveSupport::Concern

  included do
    class_attribute :obfuscated_attrs
    class_attribute :obfuscated_dependent

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
      self.obfuscated_dependent = options[:dependent]
    end
  end

  # replace displayed string with random chars, except whitespace
  # check for :dependent instance to make sure
  # NB: this checks against the in-memory dependency
  # (a freshly query will never be obfuscated)
  def obfuscate(force = false)
    if force ||
       (self.obfuscated_dependent && self.send(self.obfuscated_dependent).obfuscated?) ||
       self.obfuscated_dependent.nil?

      self.readonly!

      self.obfuscated_attrs.each do |attr|
        self[attr] = self[attr]
                       .chars
                       .map{ |c| c.ord == 32 ? c : (rand(26) + 97).chr  }
                       .join() unless self[attr].blank?
      end

      self[:obfuscated] = true
    end

    self
  end

end
