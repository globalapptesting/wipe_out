module WipeOut
  class PlanDsl
    def self.build(&block)
      dsl = PlanDsl.new
      dsl.instance_exec(&block) if block

      dsl.plan
    end

    attr_reader :plan

    delegate :destroy!, :before_save, :include_plan, to: :@plan

    def initialize(plan = Plan.new)
      @plan = plan
    end

    def wipe_out(*names, strategy: AttributeStrategies::Nullify, &block)
      strategy = block if block
      names.each do |name|
        @plan.add_attribute(name, strategy: strategy)
      end
    end

    def relation(name, plan = nil, plans: nil, &block)
      if plans
        @plan.add_relation_union(name, plans, &block)
      else
        plan = plan.plan if plan.is_a?(RootPlan)
        plan ||= PlanDsl.build(&block)
        @plan.add_relation(name, plan)
      end
    end

    def ignore(*names)
      names.each do |name|
        @plan.ignore(name)
      end
    end
  end
end
