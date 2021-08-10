module WipeOut
  module Validators
    class DefinedRelations < Base
      def call
        return if ignored?

        ar_class.reflect_on_all_associations.each do |relation|
          unless indirect_relation?(relation) || ignore_relation?(relation) || plan.relations[relation.name].present?
            result.add_error("#{ar_class.name} relation is missing: :#{relation.name}")
          end
        end
      end

      private

      def indirect_relation?(relation)
        [ActiveRecord::Reflection::ThroughReflection, ActiveRecord::Reflection::BelongsToReflection]
          .include?(relation.class)
      end

      def ignore_relation?(relation)
        plan.ignored.include?(relation.name) || config.ignored_attributes.include?(relation.name)
      end
    end
  end
end
