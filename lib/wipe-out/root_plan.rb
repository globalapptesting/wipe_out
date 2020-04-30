  module WipeOut
  class RootPlan
    def initialize(ar_class)
      @plan = Plan.new
      @ar_class = ar_class
      @plugins = []
      @config = WipeOut.config
    end

    attr_reader :ar_class, :plugins, :plan
    attr_accessor :config

    def add_plugin(plugin)
      @plugins << plugin
    end

    def validation_errors
      Validator.call(@plan, @ar_class, config: @config)
    end

    def execute(record)
      ExecuteRootPlan.call(self, record)
    end
  end
end
