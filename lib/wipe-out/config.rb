module WipeOut
  class Config
    attr_accessor :ignored_attributes

    def initialize
      @ignored_attributes = %i(id updated_at created_at archived_at)
    end

    def initialize_dup(other)
      @ignored_attributes = other.ignored_attributes.dup
    end
  end
end
