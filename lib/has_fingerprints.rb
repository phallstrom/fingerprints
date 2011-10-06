module ActiveRecord
  module HasFingerprints

    OPTIONS = {
      :class_name => 'User', 
      :method => :fingerprint
    }

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_fingerprints(options = {})
        options.reverse_merge!(OPTIONS)

        include ActiveRecord::HasFingerprints::InstanceMethods

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
        raise(NoMethodError, "HasFingerprints for #{self.class} expected #{options[:class_name]} to respond to :#{options[:method]}") unless klass.respond_to? options[:method]
        value = klass.send(options[:method])
        value = value.id if value.is_a? klass
        self.send("#{field}=", value)
      end
      protected :set_fingerprint_for
    end

  end
end
