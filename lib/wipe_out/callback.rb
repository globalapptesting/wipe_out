module WipeOut
  class Callback
    attr_reader :name

    def initialize(name, block)
      @name = name.to_sym
      @block = block
    end

    def run(execution)
      raise("Wrong arity for callback name=#{name}") if block.arity != 1

      block.call(execution)
    end

    def ==(other)
      name == other.name &&
        block == other.block
    end

    private

    attr_reader :block
  end
end
