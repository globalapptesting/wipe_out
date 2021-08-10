module WipeOut
  # Executes plan for a given record.
  # Plan execution flow:
  #   - emit event: `#before_plan`
  #
  # For each record (recursively, depth first)
  #   - emit event: `#before_execution`
  #   - emit event: `#after_execution`
  #
  # After plan had been executed (won't run if exception had been raised)
  #   - emit event: `#after_plan`
  #
  # To see how plan is defined, see {Plans::Dsl}
  # To configure, see {Config}
  #
  class Execute
    method_object :plan, :ar_class, :record

    def call
      ar_class.transaction do
        execution = Execution::Context.new(plan, record)

        execution.notify(:before_plan)

        Execution::ExecutePlan.call(execution)

        execution.notify(:after_plan)
      end
    end
  end
end
