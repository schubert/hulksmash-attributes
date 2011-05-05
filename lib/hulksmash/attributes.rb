module HulkSmash
  module Attributes
    def self.included(klass)
      klass.send :extend, HulkSmash::Attributes::ClassMethods
      unless klass.instance_methods.include?(:attributes=)
        klass.class_eval do
          attr_reader :attributes
        end
      end
      klass.send :include, HulkSmash::Attributes::InstanceMethods
    end

    module ClassMethods
      def undo(attributes = {})
        self.new(smasher.undo(attributes))
      end

      def hulk(&block)
        @smasher = Smash.new(self, &block)
      end

      def smasher
        @smasher
      end

    end

    module InstanceMethods
      def initialize(attributes = {})
        @attributes = self.class.smasher.using(attributes) if can_smash?
        super(@attributes)
      end

      def attributes=(attributes = {})
        @attributes = self.class.smasher.using(attributes) if can_smash?
      end

      def undo
        can_smash? ? self.class.smasher.undo(attributes) : attributes
      end

      private

      def can_smash?
        self.class.smasher && (self.class.smasher.smashed_attributes.any? || self.class.smasher.default_smasher.present?)
      end
    end
  end
end
