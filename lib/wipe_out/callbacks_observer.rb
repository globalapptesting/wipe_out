module WipeOut
  # @api private
  class CallbacksObserver
    def initialize(callbacks, execution)
      @callbacks = callbacks
      @execution = execution
    end

    def update(name)
      callbacks_by_name(name).each do |callback|
        callback.run(execution)
      end
    end

    private

    attr_reader :execution, :callbacks

    def callbacks_by_name(name)
      callbacks.select { |callback| callback.name == name }
    end
  end
end
