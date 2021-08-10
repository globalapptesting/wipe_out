require "observer"

module WipeOut
  module Execution
    class Context
      include Observable
      attr_reader :record, :plan, :config

      def initialize(plan, record, config = plan.config)
        @plan = plan
        @record = record
        @config = config

        add_observer(CallbacksObserver.new(plan.callbacks, self))
      end

      def run
        on_execute = plan.on_execute || config.default_on_execute

        on_execute.call(self)
      end

      def notify(name)
        changed
        notify_observers(name)
      end

      def subexecution(sub_plan, record)
        plan.callbacks.each { |callback| sub_plan.add_callback(callback) }
        self.class.new(sub_plan, record, config)
      end
    end
  end
end
