require "attr_extras"
require "forwardable"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

# When working with gem please see {file:getting_started.md}
#
# If you'd like to contribute, check out {file:development.md}
#
module WipeOut
  class << self
    extend Forwardable
    # Builds a plan for wipe out. When ActiveRecord class is passed,
    # it's a root plan and under it you can nest more plans.
    #
    # @example
    #   UserPlan = WipeOut.build_plan(User) do
    #     wipe_out :name
    #   end
    #
    #
    # For DSL documentation {Plans::Dsl}
    #
    # @param ar_class [ActiveRecord::Base] class for which the plan is being built
    # @return [Plans::Plan | Plans::RootPlan]
    #
    def build_plan(ar_class = nil, &block)
      ar_class ? Plans::RootPlanDsl.build(ar_class, &block) : Plans::Dsl.build(&block)
    end

    # Configures the gem, you should call it in the initializer
    #
    # @example
    #   WipeOut.configure do |config|
    #     config.ignored_attributes = %i[id inserted_at]
    #   end
    #
    # For additional details, {Config}.
    # You will be also able to modify config for specific plan.
    # Here you only set defaults.
    #
    # @return [Config]
    def configure
      raise "Pass block to configure the gem" unless block_given?

      yield config

      config
    end

    # Returns current configuration
    #
    # @return [Config]
    def config
      @config ||= Config.new
    end
    def_delegators :@config, :logger
  end
end

loader.eager_load
