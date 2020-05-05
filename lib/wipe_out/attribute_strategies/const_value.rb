module WipeOut
  module AttributeStrategies
    class ConstValue
      def initialize(value)
        @value = value
      end

      def call(*)
        @value
      end
    end
  end
end
