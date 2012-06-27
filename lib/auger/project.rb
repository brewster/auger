require 'host_range'

module Auger

  class Project
    attr_accessor :name, :fqdns, :hosts, :connections, :roles
    
    def self.load(name, &block)
      project = new(name)
      project.instance_eval(&block)
      project
    end

    def initialize(name)
      @name = name
      @hosts = []
      @fqdns = []
      @connections = []
      @roles = Hash.new { |h,k| h[k] = [] }
      self
    end

    def role(name, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      servers = args.map { |arg| HostRange.parse(arg) }.flatten
      servers.each { |server| roles[name] << Auger::Server.new(server, options) }
    end

    def server(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      roles = []
      servers = []
      args.each do |arg|
        case arg
        when Symbol then roles << arg
        when String then servers << arg
        else raise ArgumentError, "illegal argument to server: #{arg}"
        end
      end
      roles = [nil] if roles.empty? # default role
      roles.each { |name| role(name, *servers, options) }
    end

    alias :hosts :server

    ## return array of servers for given array of roles (default to all)
    def servers(roles = [])
      (roles.empty? ? @roles.values : @roles.values_at(*roles))
        .flatten
    end

    alias :host :hosts

    ## add fqdn or return list of fqdns
    def fqdns(*ranges)
      ranges.empty? ? @fqdns.flatten : @fqdns << [*ranges].map {|r| HostRange.parse(r)}
    end

    alias :fqdn :fqdns

    def tests
      @connections.map do |connection|
        connection.requests.map do |request|
          request.tests.map { |test| test }
        end
      end.flatten
    end

  end
  
end
