module WipeOut
  class Plan
    def initialize
      @attributes = {}
      @ignored = []
      @relations = {}
      @destroy = false
      @before_save_callbacks = []
    end

    attr_reader :attributes, :ignored, :relations, :before_save_callbacks

    def destroy?
      @destroy
    end

    def before_save(&block)
      @before_save_callbacks << block
    end

    def add_attribute(name, strategy: AttributeStrategies::Nullify)
      @attributes[name.to_sym] = strategy
    end

    def add_relation(name, plan)
      @relations[name.to_sym] = plan
    end

    def add_relation_union(name, plans, &block)
      @relations[name.to_sym] = PlansUnion.new(plans, block)
    end

    def destroy!
      @destroy = true
    end

    def ignore(name)
      @ignored << name.to_sym
    end

    def include_plan(other)
      @attributes.merge! other.attributes
      @ignored += other.ignored
      @relations.merge! other.relations
      @destroy = other.destroy?
      @before_save_callbacks += other.before_save_callbacks.dup
    end
  end
end
