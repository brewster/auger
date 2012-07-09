module Auger

  class Request 
    attr_accessor :tests, :before_tests_proc, :before_request_proc, :arg

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

    ## called within test block to return a Result object
    def Result(*args)
      Auger::Result.new(*args)
    end

    ## called within test block to return a Status object
    def Status(*args)
      Auger::Status.new(*args)
    end

    def before_request(&block)
      @before_request_proc = block
    end

    ## callback to be run after request, but before tests
    def before_tests(&block)
      @before_tests_proc = block
    end

    ## call plugin run() and return plugin-specfic response object or exception
    def do_run(conn)
      return conn if conn.is_a? Exception
      begin
        arg = @arg
        arg = self.before_request_proc.call(conn) if self.before_request_proc

        start = Time.now
        response = self.run(conn, arg)
        time = Time.now - start
        response = self.before_tests_proc.call(response) if self.before_tests_proc
        return response, time
      rescue => e
        e
      end
    end

  end
  
end
