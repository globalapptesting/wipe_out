module WipeOut
  # Validates plan has proper configuration and that all ActiveRecord class attributes
  # are explicily defined in the plan.
  # Validation is a seperate step, after plan is defined. We don't assume
  # plan is valid stadalone, this allows for plans composition.
  class Validate
    method_object :plan, :ar_class, :config

    VALIDATORS = [
      Validators::Attributes,
      Validators::DefinedRelations,
      Validators::RelationsPlans
    ].freeze

    # See {Plans::RootPlan#validation_errors}
    #
    # @return [Array<String>]
    def call
      VALIDATORS.reduce([]) do |errors, validator|
        errors.concat(validator.call(plan, ar_class, config))
      end
    end
  end
end
