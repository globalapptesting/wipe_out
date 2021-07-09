module WipeOut
  module Validators
    class RelationsPlans < Base
      def call
        plan.relations.each do |name, plan|
          relation = relation_reflection(name)
          if relation
            plan.plans.map { |potential_plan| errors.concat(WipeOut::Validate.call(potential_plan, relation.klass, config)) }
          else
            errors << "#{ar_class.name} has invalid relation: :#{name}"
          end
        end

        errors
      end

      private

      def relation_reflection(name)
        ar_class.reflect_on_association(name)
      end
    end
  end
end
