module Auger

  class Result
    attr_accessor :test, :outcome, :status

    # def initialize(test, outcome)
    #   @test = test
    #   @outcome = outcome
    # end

    # def initialize(*args)
    #   hash = args.last.is_a?(Hash) ? args.pop : {}
    #   hash.each { |k,v| puts "got hash: #{k} = #{v}" }
    #   (@outcome, @status) = args
    # end

    ## optional args are outcome, status, Hash of instance variables
    # def initialize(*args)
    #   hash = args.last.is_a?(Hash) ? args.pop : {}
    #   (@outcome, @status) = args
    #   hash.each { |k,v| self.instance_variable_set("@#{k}", v) }
    # end

    def initialize(outcome = nil, status = outcome)
      @outcome = outcome
      @status  = status
    end

  end

end
