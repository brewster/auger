require 'host_range'

module Auger

  class Config
    attr_accessor :projects
    def self.load(filename)
      config = new
      config.instance_eval(File.read(filename))
      config
    end
    
    def initialize
      @projects = []
      self
    end
    
    def project(name, &block)
      @projects << Project.load(name, &block)
    end
  end

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

  class Connection
    attr_accessor :port, :requests, :response

    def self.load(port, &block)
      connection = new(port)
      connection.instance_eval(&block)
      connection
    end

    def initialize(port)
      @port = port
      @requests = []
    end

    def do_tests
      @requests.map do |request|
        request.before_tests_proc.call(request.response) if request.before_tests_proc

        request.tests.map do |test|
          outcome = test.block.call(request.response)
          Result.new(test, outcome)
        end
      end
    end

  end

  class Request 
    attr_accessor :tests, :before_tests_proc, :response, :arg

    def self.load(arg, &block)
      request = new(arg)
      request.instance_eval(&block)
      request
    end

    def initialize(arg)
      @arg = arg
      @tests = []
    end

    def test(name, &block)
      @tests << Test.new(name, block)
    end

    ## callback to be run after request, but before tests
    def before_tests(&block)
      @before_tests_proc = block
    end

  end

  class Test
    attr_accessor :name, :block
    def initialize(name, block)
      @name = name
      @block = block
    end
  end

  class Result
    attr_accessor :test, :outcome
    def initialize(test, outcome)
      @test = test
      @outcome = outcome
    end
    
    def to_s
      case @outcome
      when MatchData then
        @outcome.captures.empty? ? "\u2713" : @outcome.captures.join(' ')
      when TrueClass then
        "\u2713"
      when FalseClass then
        "\u2717"
      when NilClass then
        "\u2717"
      else
        @outcome.to_s
      end
    end

  end

end
