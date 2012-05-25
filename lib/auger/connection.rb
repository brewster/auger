module Auger

  class Connection
    attr_accessor :port, :requests, :connection, :response

    def self.load(port, &block)
      connection = new(port)
      connection.instance_eval(&block)
      connection
    end

    def initialize(port)
      @port = port
      @requests = []
    end

  end
  
end
