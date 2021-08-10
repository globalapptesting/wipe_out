module WipeOut
  module Plugin
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def before(*names, &block)
        callback(*names.map { |name| "before_#{name}" }, &block)
      end

      def after(*names, &block)
        callback(*names.map { |name| "after_#{name}" }, &block)
      end

      def callback(*names, &block)
        names.each do |name|
          add_callback(Callback.new(name, block))
        end
      end

      def callbacks
        @callbacks ||= []
      end

      def add_callback(callback)
        callbacks << callback
      end
    end
  end
end
