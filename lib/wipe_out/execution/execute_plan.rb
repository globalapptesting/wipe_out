require "forwardable"

module WipeOut
  module Execution
    class ExecutePlan
      extend Forwardable
      method_object :execution

      def_delegators :@execution, :plan, :record

      def call
        execution.notify(:before_execution)

        process_relations
        plan.attributes.each(&method(:execute_on_attribute))

        execution.run

        execution.notify(:after_execution)
      end

      def process_relations
        plan.relations.each do |name, plan|
          relation = record.send(name)

          next unless relation.present?

          if collection?(record, name)
            relation.find_each { |record| execute_on_record(plan, record) }
          else
            execute_on_record(plan, relation)
          end
        end
      end

      def execute_on_attribute(attribute)
        name, strategy = attribute
        value = strategy.call(record, name)
        record.send("#{name}=", value)
      end

      def execute_on_record(plan, record)
        execution_plan = plan.establish_execution_plan(record)

        ExecutePlan.call(execution.subexecution(execution_plan, record))
      end

      def collection?(record, relation_name)
        record.class.reflect_on_association(relation_name).collection?
      end
    end
  end
end
