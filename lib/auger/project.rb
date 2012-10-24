require 'host_range'

module Auger

  class Project
    attr_accessor :name, :connections, :servers
    
    def self.load(name, &block)
      project = new(name)
      project.instance_eval(&block)
      project
    end

    def initialize(name)
      @name = name
      @servers = []
      @connections = []
      self
    end

    ## set server, or list of server names, with optional roles and options
    ## e.g. server server1, server2, :roleA, :roleB, options => values
    def server(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      roles = args.select { |arg| arg.class == Symbol }
      servers = args.select { |arg| arg.class == String }.map { |arg| HostRange.parse(arg) }
      @servers += servers.flatten.map do |name|
        Auger::Server.new(name, *roles, options)
      end
    end

    ## get list of server objects (optionally matching list of roles)
    def servers(*roles)
      if roles.empty?
        @servers
      else
        roles.map do |role|
          @servers.select { |server| server.roles.include?(role) }
        end.flatten.uniq
      end
    end

    ## return all connections, or those matching list of roles;
    ## connections with no roles match all, or find intersection with roles list
    def connections(*roles)
      if roles.empty?
        @connections
      else
        @connections.select { |c| c.roles.empty? or !(c.roles & roles).empty? }
      end
    end

    ## return list of all test objects for this project
    def tests
      @connections.map do |connection|
        connection.requests.map do |request|
          request.tests.map { |test| test }
        end
      end.flatten
    end

  end
  
end
