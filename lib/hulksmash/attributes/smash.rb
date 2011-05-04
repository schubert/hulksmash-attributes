module HulkSmash

  module Attributes
    class Smash
      attr_accessor :smashed_attributes, :unsmashed_attributes
      def initialize(&block)
        @smashed_attributes ||= {}
        @unsmashed_attributes ||= {}
        instance_eval &block
      end
            
      def smash(attribute, user_options = {})
        raise(HulkSmash::Angry, "You must provide an :into option") unless user_options.has_key?(:into)
        into_attribute = user_options.delete(:into)
        options = { using: ->(value) { value}, undo: ->(value) { value } }.merge(user_options)
        
        self.smashed_attributes[attribute] = {into: into_attribute, using: options.delete(:using) }
        self.unsmashed_attributes[into_attribute] = {into: attribute, using: options.delete(:undo) }
        self
      end
      
      def using(attributes)
        smash_attributes(attributes, smashed_attributes)
      end
      
      def undo(attributes)
        smash_attributes(attributes, unsmashed_attributes)
      end
      
      private
      
      def smash_attributes(attributes, smasher)
        attributes.inject({}) do |result, key_value| 
          original_key, value = key_value
          key = smasher[original_key][:into] if smasher.has_key?(original_key)
          result[key] = smasher[original_key][:using].call(value) 
          result
        end
      end
    end
  end
end