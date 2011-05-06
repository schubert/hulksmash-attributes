module HulkSmash

  module Attributes
    class Smash
      OBLIVION = nil
      BITS = nil
      TINY_PIECES = nil
      TINY_LITTLE_PIECES = nil

      attr_accessor :smashed_attributes, :unsmashed_attributes, :default_smasher, :undefault_smasher

      def initialize(klass, &block)
        @smashed_attributes ||= {}
        @unsmashed_attributes ||= {}
        @klass = klass
        instance_eval &block
      end

      def smash(attribute, user_options = {})
        raise(HulkSmash::Angry, "You must provide an :into option") unless user_options.has_key?(:into)

        options = { using: anything, undo: anything }.merge(user_options)

        into = options[:into]
        undo = options[:undo]
        using = options[:using]

        self.smashed_attributes[attribute] = {into: into, using: using }
        self.unsmashed_attributes[into] = {into: attribute, using: undo }

        add_attribute_to_attr_accessible(into) if has_attribute_protection?
        self
      end

      def default(undo_key_proc, user_options = {})
        options = { into: anything, using: anything, undo: anything }.merge(user_options)
        into = options[:into]
        undo = options[:undo]
        using = options[:using]

        self.default_smasher = { into: into, using: using }
        self.undefault_smasher = { into: undo_key_proc, using: undo }
        self
      end

      def using(attributes)
        smash_attributes(attributes, smashed_attributes, default_smasher)
      end

      def undo(attributes)
        smash_attributes(attributes, unsmashed_attributes, undefault_smasher)
      end

      def anything
        ->(value) { value }
      end

      private

      def add_attribute_to_attr_accessible(attribute)
        @klass.attr_accessible attribute
      end

      def has_attribute_protection?
        @klass.ancestors.map(&:to_s).include?("ActiveModel::MassAssignmentSecurity")
      end

      def smash_attributes(attributes, smasher, default)
        attributes.inject({}) do |result, (original_key, value)|
          if smasher.has_key? original_key
            key = smasher[original_key][:into]
            result[key] = smasher[original_key][:using].call(value) unless key.nil?
          elsif default.present?
            key = default[:into].call(original_key)
            result[key] = default[:using].call(value) unless key.nil?
          else
            result[original_key] = value
          end
          result
        end
      end
    end
  end
end
