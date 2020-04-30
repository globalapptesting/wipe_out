module WipeOut
  class RootPlanDsl < PlanDsl
    def self.build(ar_class, &block)
      dsl = RootPlanDsl.new(RootPlan.new(ar_class))
      dsl.instance_exec(&block) if block
      dsl.root_plan
    end

    attr_reader :root_plan

    def initialize(root_plan)
      @root_plan = root_plan
      @plan = @root_plan.plan
    end

    def plugins(*plugins)
      plugins.each do |plugin|
        @root_plan.add_plugin(plugin)
      end
    end

    def config(&block)
      config = root_plan.config.dup
      yield config
      @root_plan.config = config
    end

    alias plugin plugins
  end
end
