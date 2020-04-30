require "attr_extras"

require_relative "wipe-out/attribute_strategies/const_value"
require_relative "wipe-out/attribute_strategies/nullify"
require_relative "wipe-out/attribute_strategies/randomize"
require_relative "wipe-out/config"
require_relative "wipe-out/execute"
require_relative "wipe-out/execute_around"
require_relative "wipe-out/execute_root_plan"
require_relative "wipe-out/plan"
require_relative "wipe-out/plan_dsl"
require_relative "wipe-out/plans_union"
require_relative "wipe-out/plugin_base"
require_relative "wipe-out/root_plan"
require_relative "wipe-out/root_plan_dsl"
require_relative "wipe-out/validator"
require_relative "wipe-out/validators/attributes"
require_relative 'wipe-out/validators/relations'

module WipeOut
  class << self
    def build_root_plan(ar_class, &block)
      RootPlanDsl.build(ar_class, &block)
    end

    def build_plan(&block)
      PlanDsl.build(&block)
    end

    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end
  end
end
