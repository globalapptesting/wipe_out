module WipeOut
  module Validators
    class Base
      method_object :plan, :ar_class, :config

      private

      def errors
        @errors ||= []
      end
    end
  end
end
