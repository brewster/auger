module Auger

  class Status
    VALUES = [:ok, :warn, :error, :exception]
    attr_accessor :value
    
    def initialize(value)
      raise ArgumentError, "illegal status value" unless VALUES.include? value
      @value = value
    end

    def to_s
      @value.to_s
    end

  end
  
end
