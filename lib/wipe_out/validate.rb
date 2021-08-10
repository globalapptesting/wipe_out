module WipeOut
  # Validates plan has proper configuration and that all ActiveRecord class attributes
  # are explicily defined in the plan.
  # Validation is a seperate step, after plan is defined. We don't assume
  # plan is valid stadalone, this allows for plans composition.
  class Validate
    method_object :plan, :ar_class, :config, [:result]

    VALIDATORS = [
      Validators::Attributes,
      Validators::DefinedRelations,
      Validators::RelationsPlans
    ].freeze

    # See {Plans::BuiltPlan#validate}
    #
    # @return [Array<String>]
    def call
      VALIDATORS.map do |validator|
        validator.call(plan, ar_class, config, result)
      end

      result
    end

    private

    def result
      @result ||= ValidationResult.new
    end
  end

  class ValidationResult
    attr_reader :errors

    def initialize
      @errors = []
    end

    def valid?
      !errors.any?
    end

    def add_error(message)
      @errors << message
    end
  end
end
