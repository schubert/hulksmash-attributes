module HulkSmash
  class Angry < Exception
    def initialize(message)
      @message = message
    end

    def message
      @message
    end
  end
end

require "hulksmash/attributes"
require "hulksmash/attributes/smash"
