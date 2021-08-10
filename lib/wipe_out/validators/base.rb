module WipeOut
  module Validators
    class Base
      method_object :plan, :ar_class, :config, :result

      private

      def ignored?
        plan.ignored == [WipeOut::IGNORE_ALL]
      end
    end
  end
end
