require "attr_extras"
require "active_support/core_ext/module/delegation"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

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

loader.eager_load
