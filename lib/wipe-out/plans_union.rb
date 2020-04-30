module WipeOut
  class PlansUnion
    attr_reader :plans

    def initialize(plans, selector)
      @plans = plans
      @selector = selector
    end

    def establish_execution_plan(record)
      plan = @selector.call(record)
      unless @plans.include?(plan)
        raise "Plan #{plan} is not listed in #{@plans}"
      end

      plan
    end
  end
end
