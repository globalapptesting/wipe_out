require "forwardable"

module WipeOut
  module Plans
    # Provides DSL methods available during {Plan} building.
    class Dsl
      extend Forwardable
      # {#WipeOut.build_plan WipeOut.build_plan} should be used instead
      #
      # @!visibility private
      def self.build(&block)
        dsl = Dsl.new
        dsl.instance_exec(&block) if block

        dsl.plan
      end

      # @!visibility private
      attr_reader :plan

      # @!method destroy!
      #   Marks object for destroy! It will take precedence over anything else.
      #
      #   @return [nil]
      #
      # @!method before_save!
      #   Called just before any action is taken on the attribute
      #   like destroy or wipe out.
      #
      #   @todo verify that before_save is not called for destroy
      #   @return [nil]
      #
      # @!method include_plan!
      #
      #   Combines plan with another one. You can use it to create plans
      #   out of other plans via composition.
      #
      #   @return {nil}
      def_delegators :@plan, :destroy!, :before_save, :include_plan

      # @!visibility private
      def initialize(plan = Plan.new)
        @plan = plan
      end

      # Defines a strategy for removing data inside attribute(s)
      #
      # @param names [Array<Symbol>] any number of attributes to wipe out
      # @param strategy [#call] defined a strategy which should be used for wiping out the attribute(s).
      #   You can also define a strategy inline by passing a block.
      #   By default it uses {AttributeStrategies::Nullify}.
      # @return [nil]
      def wipe_out(*names, strategy: AttributeStrategies::Nullify, &block)
        strategy = block if block
        names.each do |name|
          @plan.add_attribute(name, strategy: strategy)
        end
      end

      # Configures plan for wiping out data in relation. You must pass a block
      # and use the same DSL to configure it.
      #
      # @todo Add Spec for plan unions
      #
      # @return [nil]
      def relation(name, plan = nil, plans: nil, &block)
        if plans
          @plan.add_relation_union(name, plans, &block)
        else
          plan ||= Dsl.build(&block)
          @plan.add_relation(name, plan)
        end
      end

      # Sets given attribute(s) as ignored. Attributes must be ignored explicily
      # otherwise errors will be raised during validation
      #
      # @param names [Array<Symbol>] any number of attributes to ignore
      # @return [nil]
      def ignore(*names)
        names.each do |name|
          @plan.ignore(name)
        end
      end
    end
  end
end
