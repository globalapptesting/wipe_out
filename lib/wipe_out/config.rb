module WipeOut
  # Holds configuration for the gem.
  #
  # Configuration options:
  #
  #   - ignored_attributes - default: `%i[id updated_at created_at archived_at]`
  #     these attributes will be ignored in every plan by default.
  #   - logger - default: Rails.logger
  #
  class Config
    attr_accessor :ignored_attributes, :logger

    def initialize
      @ignored_attributes = %i[id updated_at created_at archived_at]
      @logger = Rails.logger
    end

    def dup
      config = self.class.new
      config.ignored_attributes = ignored_attributes
      config.logger = logger
      config
    end
  end
end
