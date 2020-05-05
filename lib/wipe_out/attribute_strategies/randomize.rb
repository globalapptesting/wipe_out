module WipeOut
  module AttributeStrategies
    class Randomize
      def initialize(format: "destroyed_%s")
        @format = format
      end

      def call(*)
        @format % SecureRandom.hex(10)
      end
    end
  end
end
