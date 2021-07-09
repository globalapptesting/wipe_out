module WipeOut
  module Plans
    class RootPlan < Plan
      def initialize(ar_class)
        @ar_class = ar_class
        @plugins = []
        @config = WipeOut.config.dup
        super()
      end

      attr_reader :ar_class, :plugins, :config

      # Adds plugin to a list of executed plugins **during execution**
      def add_plugin(plugin)
        @plugins << plugin
      end

      # Validates and returns any errors if validation fails.
      #
      # It's not done automatically when plan is defined because plans
      # can be combined and not be valid standalone.
      #
      # @return [Array<String>] empty if everything is OK with the plan.
      #   Returns non-empty list if issues are detected.
      #   You should call it in tests to ensure that plans OK.
      def validation_errors
        WipeOut::Validate.call(self, ar_class, config)
      end

      # Executes plan on a record
      def execute(record)
        WipeOut::Execution::ExecuteRootPlan.call(self, record)
      end
    end
  end
end
