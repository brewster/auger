module Auger

  class Connection
    attr_accessor :requests, :connection, :response, :roles, :options

    def self.load(port, &block)
      connection = new(port)
      connection.instance_eval(&block)
      connection
    end

    def initialize(port)
      @options = {:port => port, :timeout => 5}
      @roles = []
      @requests = []
    end

    def roles(*names)
      @roles += names if names
      @roles
    end

    ## explicit method to override use of timeout.rb in modules
    def timeout(secs)
      @options[:timeout] = secs
    end

    def method_missing(method, arg)
      @options[method] = arg
    end

    ## call plugin open() and return plugin-specific connection object, or exception
    def do_open(server)
      options = @options.merge(server.options)
      begin
        self.open(server.name, options)
      rescue => e
        e
      end
    end
    
  end
  
end
