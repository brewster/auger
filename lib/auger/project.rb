require 'host_range'

module Auger

  class Project
    attr_accessor :name, :fqdns, :hosts, :connections
    
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
      self
    end

    ## add host or return list of hosts
    def hosts(*ranges)
      ranges.empty? ? @hosts.flatten : @hosts << ranges.map {|r| HostRange.parse(r)}
    end

    alias :host :hosts

    ## add fqdn or return list of fqdns
    def fqdns(*ranges)
      ranges.empty? ? @fqdns.flatten : @fqdns << [*ranges].map {|r| HostRange.parse(r)}
    end

    alias :fqdn :fqdns

  end
  
end
