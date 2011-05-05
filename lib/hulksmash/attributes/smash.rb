module HulkSmash

  module Attributes
    class Smash
      attr_accessor :smashed_attributes, :unsmashed_attributes, :default_smasher

      def initialize(klass, &block)
        @smashed_attributes ||= {}
        @unsmashed_attributes ||= {}
        @klass = klass
        instance_eval &block
      end

      def smash(attribute, user_options = {})
        raise(HulkSmash::Angry, "You must provide an :into option") unless user_options.has_key?(:into)

        options = { using: ->(value) { value }, undo: ->(value) { value } }.merge(user_options)

        into = options[:into]
        undo = options[:undo]
        using = options[:using]

        self.smashed_attributes[attribute] = {into: into, using: using }
        self.unsmashed_attributes[into] = {into: attribute, using: undo }

        add_attribute_to_attr_accessible(into) if has_attribute_protection?
        self
      end

      def default(key_proc, user_options = {})
        @default_smasher = { key: key_proc, using: ->(value) { value }, undo: ->(value) { value } }.merge(user_options)
        self
      end

      def using(attributes)
        smash_attributes(attributes, smashed_attributes)
      end

      def undo(attributes)
        smash_attributes(attributes, unsmashed_attributes)
      end

      private

      def add_attribute_to_attr_accessible(attribute)
        @klass.attr_accessible attribute
      end

      def has_attribute_protection?
        @klass.ancestors.map(&:to_s).include?("ActiveModel::MassAssignmentSecurity")
      end

      def smash_attributes(attributes, smasher)
        attributes.inject({}) do |result, (original_key, value)|
          if smasher.has_key? original_key
            key = smasher[original_key][:into]
            result[key] = smasher[original_key][:using].call(value)
          elsif default_smasher.present?
            key = default_smasher[:key].call(original_key)
            result[key] = default_smasher[:using].call(value)
          else
            result[original_key] = value
          end
          result
        end
      end
    end
  end
end
