module WipeOut
  module Validators
    class Attributes < Base
      def call
        return if ignored?

        if missing_attributes.any?
          names = missing_attributes.map { |name| ":#{name}" }.join(", ")

          result.add_error("#{ar_class.name} plan is missing attributes: #{names}")
        end

        if non_existing_attributes.any?
          names = non_existing_attributes.map { |name| ":#{name}" }.join(", ")

          result.add_error("#{ar_class.name} plan has extra attributes: #{names}")
        end
      end

      private

      def missing_attributes
        columns - attributes - ignored_attributes - foreign_keys
      end

      def non_existing_attributes
        attributes - columns
      end

      def columns
        ar_class.columns.map(&:name).map(&:to_sym)
      end

      def attributes
        plan.attributes.keys
      end

      def ignored_attributes
        plan.ignored + config.ignored_attributes
      end

      def foreign_keys
        ar_class.reflect_on_all_associations.find_all do |relation|
          relation.is_a?(ActiveRecord::Reflection::BelongsToReflection)
        end.map(&:foreign_key).map(&:to_sym)
      end
    end
  end
end
