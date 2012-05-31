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

    ## returns array of Auger::Result objects for tests
    def do_tests
      ## callback to be run before tests
      if self.before_tests_proc
        self.before_tests_proc.call(@response) rescue @response = $!
      end

      ## run tests
      @tests.map do |test|
        outcome = @response.is_a?(Exception) ? @response : test.run(@response)
        Auger::Result.new(test, outcome)
      end
    end

  end
  
end
