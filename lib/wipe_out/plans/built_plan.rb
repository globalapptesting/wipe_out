module WipeOut
  module Plans
    # Provides final API after the plan had been build
    #
    # Under the hood it contains plans but hides our under the hood
    # implemention where we have helper methods for adding relations, attributes, etc.
    class BuiltPlan
      extend Forwardable

      def initialize(plan)
        @plan = plan
      end

      def_delegators :plan, :config
      attr_reader :plan

      # Validates and returns any errors if validation fails.
      #
      # It's not done automatically when plan is defined because plans
      # can be combined and not be valid standalone.
      #
      # @return [Array<String>] empty if everything is OK with the plan.
      #   Returns non-empty list if issues are detected.
      #   You should call it in tests to ensure that plans are OK.
      def validate(ar_class)
        WipeOut::Validate.call(plan, ar_class, @plan.config)
      end

      # Executes plan on a record
      def execute(record)
        WipeOut::Execute.call(plan, record.class, record)
      end
    end
  end
end
