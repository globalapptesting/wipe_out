module WipeOut
  class PluginBase
    def around_all(_plan)
      yield
    end

    def around_each(_plan, _record)
      yield
    end
  end
end
