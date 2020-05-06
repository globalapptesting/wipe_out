module WipeOut
  class ExecuteAround
    method_object :callback_name, :arguments, :plugins

    def call(&block)
      execute_around(plugins, &block)
    end

    private

    def execute_around(plugins, &block)
      current_plugin, *rest = plugins
      if current_plugin.nil?
        yield
      else
        current_plugin.send(callback_name, *arguments) do
          execute_around(rest, &block)
        end
      end
    end
  end
end
