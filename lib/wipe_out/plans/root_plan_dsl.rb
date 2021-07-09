module WipeOut
  module Plans
    class RootPlanDsl < Dsl
      # {#WipeOut.build_plan WipeOut.build_plan} should be used instead
      # RootPlanDsl has all the same DSL option as {PlanDsl} and additionally
      # you can configure plugins
      #
      # @!visibility private
      def self.build(ar_class, &block)
        dsl = RootPlanDsl.new(RootPlan.new(ar_class))
        dsl.instance_exec(&block) if block
        dsl.root_plan
      end

      # @!visibility private
      attr_reader :root_plan

      # @!visibility private
      def initialize(root_plan)
        @root_plan = root_plan
        super(@root_plan)
      end

      # Adds a plugin to the plan.
      # What are plugins? See {Plugin}
      #
      def plugins(*plugins)
        plugins.each do |plugin|
          @root_plan.add_plugin(plugin)
        end
      end
      alias_method :plugin, :plugins

      # See {Config} to check what options are available.
      # @todo add test for nested configurations
      # @return [Config]
      def configure
        yield root_plan.config

        config
      end
    end
  end
end
