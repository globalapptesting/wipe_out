module WipeOut
  module Validators
    class RelationsPlans < Base
      def call
        return if ignored?

        plan.relations.each do |name, plan|
          relation = relation_reflection(name)
          if relation
            plan.plans.each do |potential_plan|
              WipeOut::Validate.call(potential_plan, relation.klass, config, result: result)
            end
          else
            result.add_error("#{ar_class.name} has invalid relation: :#{name}")
          end
        end
      end

      private

      def relation_reflection(name)
        ar_class.reflect_on_association(name)
      end
    end
  end
end
