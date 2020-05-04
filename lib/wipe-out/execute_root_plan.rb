require "active_support/core_ext/module/delegation"

module WipeOut
  class ExecuteRootPlan
    method_object :root_plan, :record

    delegate :plan, :plugins, to: :root_plan

    def call
      ExecuteAround.call(:around_all, [plan], plugins) do
        record.transaction do
          Execute.call(plan, record, plugins)
        end
      end
    end
  end
end
