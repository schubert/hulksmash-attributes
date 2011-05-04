module HulkSmash
  module Attributes
    def self.included(klass)
      klass.send :extend, HulkSmash::Attributes::ClassMethods
      unless klass.instance_methods.include?(:attributes=)
        klass.class_eval do
          attr_accessor :attributes
        end
      end
      klass.send :include, HulkSmash::Attributes::InstanceMethods
    end

    module ClassMethods
      def undo(attributes = {})
        self.new(smasher.undo(attributes))
      end

      def hulk(&block)
        @smasher = Smash.new(&block)
      end

      def smasher
        @smasher
      end

    end

    module InstanceMethods
      def initialize(attrs = {})
        attributes = self.class.smasher.using(attrs) if self.class.smasher
        super(attributes)
      end

      def undo
        self.class.smasher.present? ? self.class.smasher.undo(attributes) : attributes
      end
    end
  end
end