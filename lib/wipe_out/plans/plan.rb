module WipeOut
  module Plans
    class Plan
      def initialize(config)
        @attributes = {}
        @ignored = []
        @callbacks = []
        @relations = {}
        @on_execute = nil
        @config = config
      end

      attr_reader :attributes, :ignored, :relations, :callbacks, :config

      def add_attribute(name, strategy:)
        @attributes[name.to_sym] = strategy
      end

      def add_relation(name, plan)
        @relations[name.to_sym] = plan
      end

      def add_relation_union(name, plans, &block)
        @relations[name.to_sym] = Union.new(plans, block)
      end

      def on_execute(arg = nil, &block)
        @on_execute = arg || block || @on_execute
      end

      def ignore(name)
        @ignored << name.to_sym
      end

      def include_plan(other)
        @attributes.merge! other.attributes
        @ignored += other.ignored
        @relations.merge! other.relations
        @on_execute = other.on_execute
        other.callbacks.each do |callback|
          @callbacks << callback
        end
      end

      # Duck typing for plans union
      def plans
        [self]
      end

      def establish_execution_plan(_record)
        self
      end

      def add_callback(callback)
        @callbacks << callback
      end

      def inspect
        "Plan(attributes=#{attributes.keys})"
      end
    end
  end
end
