module WipeOut
  module Plans
    class Union
      attr_reader :plans

      def initialize(plans, selector)
        @plans = plans
        @selector = selector
      end

      def establish_execution_plan(record)
        plan = @selector.call(record).plan
        raise "Plan #{plan} is not listed in #{@plans}" unless @plans.include?(plan)

        plan
      end
    end
  end
end
