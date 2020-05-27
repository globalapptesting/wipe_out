module WipeOut
  class Execute
    method_object :plan, :record, :plugins

    def call
      around_each do
        plan.attributes.each do |name, strategy|
          value = strategy.call(record, name)
          record.send("#{name}=", value)
        end

        process_relations(plan.relations)

        plan.before_save_callbacks.each do |callback|
          callback.call(record)
        end

        if plan.destroy?
          record.destroy!
        else
          Rails.logger.info("[wipe_out-invalid-record] #{record.inspect}") unless record.valid?
          record.save(validate: false)
        end
      end
    end

    def collection?(record, relation_name)
      record.class.reflect_on_association(relation_name).collection?
    end

    private

    def process_relations(relations)
      relations.each do |name, plan|
        relation = record.send(name)

        next unless relation.present?

        if collection?(record, name)
          relation.each do |entity|
            execution_plan = relation_execution_plan(plan, entity)
            Execute.call(execution_plan, entity, plugins)
          end
        else
          execution_plan = relation_execution_plan(plan, relation)
          Execute.call(execution_plan, relation, plugins)
        end
      end
    end

    def relation_execution_plan(plan, record)
      if plan.is_a?(PlansUnion)
        relation_execution_plan(plan.establish_execution_plan(record), record)
      else
        plan
      end
    end

    def around_each(&block)
      ExecuteAround.call(:around_each, [plan, record], plugins, &block)
    end
  end
end
