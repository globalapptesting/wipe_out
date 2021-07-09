module WipeOut
  module Execution
    class ExecuteRootPlan
      method_object :plan, :record

      def call
        ExecuteAround.call(:around_all, [plan], plan.plugins) do
          record.transaction do
            Execute.call(plan, record, plan.plugins)
          end
        end
      end
    end
  end
end
