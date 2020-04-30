module WipeOut
  module Validators
    class Relations
      method_object :plan, :ar_class, :config

      def call
        errors = []
        ar_class.reflect_on_all_associations.each do |relation|
          unless indirect_relation?(relation) || ignore_relation?(relation) || plan.relations[relation.name].present?
            errors << "#{ar_class.name} relation is missing: #{relation.name}"
          end
        end

        errors
      end

      private

      def indirect_relation?(relation)
        [ActiveRecord::Reflection::ThroughReflection, ActiveRecord::Reflection::BelongsToReflection].include?(relation.class)
      end

      def ignore_relation?(relation)
        plan.ignored.include?(relation.name) || config.ignored_attributes.include?(relation.name)
      end
    end
  end
end
