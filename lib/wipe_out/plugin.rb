module WipeOut
  # Defines plugin callbacks called during plan execution.
  # @todo See {Execute} for plans to change how plugins work
  class Plugin
    def around_all(_plan)
      yield
    end

    def around_each(_plan, _record)
      yield
    end
  end
end
