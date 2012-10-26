require 'net/ssh/gateway'
module Auger

  class Connection
    attr_accessor :requests, :connection, :response, :roles, :options, :gateway

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

    ## setup options and call appropriate connection open()
    def try_open(server)
      options = @options.merge(server.options) # merge connection and server options
      options[:tunnel] ? try_open_tunnel(server, options) : try_open_direct(server, options)
    end

    ## call plugin open() and return plugin-specific connection object, or exception
    def try_open_direct(server, options)
      begin
        self.open(server.name, options)
      rescue => e
        e
      end
    end
    
    ## call plugin open() via an ssh tunnel
    def try_open_tunnel(server, options)
      host, user = options[:tunnel].split('@').reverse #for ssh to the gateway host
      user ||= ENV['USER']
      begin
        @gateway = Net::SSH::Gateway.new(host, user)
        gateway.open(server.name, options[:port]) do |port|
          self.open('127.0.0.1', options.merge({:port => port}))
        end
      rescue => e
        e
      end
    end

    ## safe way to call plugin close() (rescue if the connection did not exist)
    def try_close(conn)
      begin
        self.close(conn)
        @gateway.shutdown! if @gateway
      rescue => e
        e
      end
    end

  end
  
end
