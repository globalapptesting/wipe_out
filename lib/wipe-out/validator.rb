module WipeOut
  class Validator
    method_object :plan, :ar_class, [:errors, :config!]

    def call
      unless plan.destroy?
        errors.concat Validators::Attributes.call(plan, ar_class, config)
      end
      errors.concat Validators::Relations.call(plan, ar_class, config)

      validate_nested

      errors
    end

    private

    def errors
      @errors ||= []
    end

    def validate_nested
      plan.relations.each do |name, plan|
        relation = relation_reflection(name)
        if relation
          plans(plan).each do |potential_plan|
            Validator.call(potential_plan, relation.klass, errors: errors, config: config)
          end
        else
          errors << "#{ar_class.name} has invalid relation: :#{name}"
        end
      end
    end

    def relation_reflection(name)
      ar_class.reflect_on_association(name)
    end

    def plans(plan)
      if plan.is_a?(PlansUnion)
        plan.plans
      else
        [plan]
      end
    end
  end
end
