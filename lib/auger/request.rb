module Auger

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
  
end
