module Auger

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
  
end
