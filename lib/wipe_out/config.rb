module WipeOut
  # Holds configuration for the gem.
  #
  # Configuration options:
  #
  #   - ignored_attributes - default: `%i[id updated_at created_at archived_at]`
  #     these attributes will be ignored in every plan by default.
  #   - logger - default: Rails.logger
  #   - default_on_execute - default: calls `save!` on record
  #
  class Config
    # @!visibility private
    attr_accessor :ignored_attributes, :logger, :default_on_execute

    def initialize
      @default_on_execute = ->(execution) { execution.record.save! }
      @ignored_attributes = %i[id updated_at created_at archived_at]
      @logger = Rails.logger
    end

    # Duplicates config
    def dup
      config = self.class.new
      config.ignored_attributes = ignored_attributes
      config.logger = logger
      config.default_on_execute = default_on_execute
      config
    end
  end
end
