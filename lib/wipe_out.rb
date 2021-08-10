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
  IGNORE_ALL = :ignore_all

  class << self
    extend Forwardable
    # Builds a plan for wipe out. When ActiveRecord class is passed,
    #
    # @example
    #   UserPlan = WipeOut.build_plan do
    #     wipe_out :name
    #   end
    #
    #
    # For DSL documentation {Plans::Dsl}
    #
    # @return [Plans::BuiltPlan]
    #
    def build_plan(config: nil, &block)
      config ||= WipeOut.config.dup
      plan = Plans::Plan.new(config)
      Plans::Dsl.build(plan, &block)
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
