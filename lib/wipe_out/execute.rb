module WipeOut
  # Executes plan for given record.
  # Calling all plugins with callbacks.
  #
  # Records are saved with `#save!` and `#destroy!`.
  # Everything happens within transaction(`record#transaction {  }`)
  #
  # @todo Provide options to customize/set how records are saved and destroyed
  # @todo By default save should raise errors
  # @todo refactor callbacks into something that resembled FactoryBot callbacks or [ActiveModel::Callbacks]
  #
  class Execute
    method_object :plan, :record, :plugins

    # See {Plans::RootPlan#execute}
    def call
      around_each do
        plan.attributes.each(&method(:execute_on_attribute))
        process_relations

        plan.before_save_callbacks.each do |callback|
          callback.call(record)
        end

        if plan.destroy?
          WipeOut.logger.debug("[WipeOut] RecordDestroy #{record.inspect}")
          record.destroy!
        else
          WipeOut.logger.info("[WipeOut] RecordInvalid #{record.inspect}") unless record.valid?
          record.save(validate: false)
        end
      end
    end

    private

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
      execution_plan = relation_execution_plan(plan, record)
      Execute.call(execution_plan, record, plugins)
    end

    def collection?(record, relation_name)
      record.class.reflect_on_association(relation_name).collection?
    end

    # @todo Can we refactor it so that no union detection would be possible?
    def relation_execution_plan(plan, record)
      if plan.union?
        relation_execution_plan(plan.establish_execution_plan(record), record)
      else
        plan
      end
    end

    def around_each(&block)
      Execution::ExecuteAround.call(:around_each, [plan, record], plugins, &block)
    end
  end
end
