require 'active_record'
require 'fingerprints/active_record'
require 'fingerprints/version'

module Fingerprints
  OPTIONS = {
    :class_name => 'User'
  }

  module Extensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def has_fingerprints(options = {})
        options.reverse_merge!(OPTIONS)

        class_eval <<-"EOV"
          class << self
            def fingerprint
              Thread.current["fingerprint_for_#{self.class}"]
            end
            def fingerprint=(val)
              Thread.current["fingerprint_for_#{self.class}"] = val
            end
          end
        EOV
      end

      def leaves_fingerprints(options = {})
        options.reverse_merge!(OPTIONS)

        include Fingerprints::Extensions::InstanceMethods

        belongs_to :creator, :class_name => options[:class_name], :foreign_key => 'created_by'
        belongs_to :updater, :class_name => options[:class_name], :foreign_key => 'updated_by'
        before_create :fingerprint_created_by
        before_update :fingerprint_updated_by
        define_method('fingerprint_created_by') {|*args| set_fingerprint_for(:created_by, options) }
        define_method('fingerprint_updated_by') {|*args| set_fingerprint_for(:updated_by, options) }
      end
    end 

    module InstanceMethods
      def set_fingerprint_for(field, options = {})
        klass = options[:class_name].constantize
        raise(NoMethodError, "HasFingerprints for #{self.class} expected #{options[:class_name]} to respond to :fingerprint") unless klass.respond_to? :fingerprint
        value = klass.fingerprint
        value = value.id if value.is_a? klass
        self.send("#{field}=", value)
      end
      protected :set_fingerprint_for
    end

  end
end

ActiveRecord::Base.send :include, Fingerprints::Extensions
