require "forwardable"

module WipeOut
  module Plans
    # Provides DSL methods available during {Plan} building.
    class Dsl
      extend Forwardable
      include WipeOut::Plugin::ClassMethods
      # {#WipeOut.build_plan WipeOut.build_plan} should be used instead
      #
      # @!visibility private
      def self.build(plan, &block)
        dsl = Dsl.new(plan)
        dsl.instance_exec(&block)

        BuiltPlan.new(dsl.plan)
      end

      # @!visibility private
      attr_reader :plan

      # @!method on_execute
      #   Overwrites default `#save!` which is called on record after wipe out.
      #   You can use this to switch to `#destroy!` or `#delete!` if needed.
      #   You can also configure this in {Config}
      #
      #   @yield [WipeOut::Execution::Context] execution
      #   @return [nil]
      #
      # @!method include_plan!(other_plan)
      #
      #   Combines plan with another one. You can use it to create plans
      #   out of other plans via composition.
      #
      #   @param [WipeOut::Plans::Plan] other_plan
      #   @return {nil}
      def_delegators :@plan, :on_execute

      # @!visibility private
      def initialize(plan)
        @plan = plan
      end

      # @!visibility private
      def plugin(plugin)
        plugin.callbacks.each { |callback| add_callback(callback) }
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
          plan.add_attribute(name, strategy: strategy)
        end
      end

      # Configures plan for wiping out data in relation. You must pass a block
      # and use the same DSL to configure it.
      #
      # @return [nil]
      def relation(name, plan = nil, plans: nil, &block)
        if plans
          plans.each do |build_plan|
            forward_callbacks(@plan, build_plan.plan)
          end

          @plan.add_relation_union(name, plans.map(&:plan), &block)
        else
          plan ||= Plan.new(@plan.config)
          plan = plan.plan if plan.is_a?(BuiltPlan)
          dsl = Dsl.new(plan)
          dsl.instance_exec(&block) if block.present?
          forward_callbacks(@plan, plan)

          @plan.add_relation(name, dsl.plan)
        end
      end

      # Sets given attribute(s) as ignored. Attributes must be ignored explicily
      # otherwise errors will be raised during validation
      #
      # @param names [Array<Symbol>] any number of attributes to ignore
      # @return [nil]
      def ignore(*names)
        names.each do |name|
          plan.ignore(name)
        end
      end

      # Ignores all attributes and relations during validation.
      # It should be used when you're using custom `#on_execute` method that
      # for example destroys records and you don't care what attributes are there exactly
      def ignore_all
        plan.ignore(WipeOut::IGNORE_ALL)
      end

      def include_plan(built_plan)
        plan.include_plan(built_plan.plan)
      end

      # See {Config} to check what options are available.
      # @todo add test for nested configurations inside plans
      # @return [Config]
      def configure
        yield plan.config

        plan.config
      end

      # @!visibility private
      def add_callback(callback)
        plan.add_callback(callback)
      end

      # @!visibility private
      def forward_callbacks(source_plan, destination_plan)
        source_plan.callbacks.each { |callback| destination_plan.add_callback(callback) }
      end
    end
  end
end
