module Auger

  class Test
    attr_accessor :name, :block, :id

    def initialize(name, block)
      @name = name
      @block = block
    end

    ## return Auger::Result object with outcome of test
    def run(response)
      outcome =
        if response.is_a?(Exception) or @block.nil?
          response
        else
          @block.call(response) rescue $! # run the test
        end

      result = outcome.is_a?(Result) ? outcome : Auger::Result.new(outcome)
      result.test = self
      result
    end

  end

end
