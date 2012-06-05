module Auger
  
  class Test
    attr_accessor :name, :block

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
          @block.call(response) rescue $!
        end

      Auger::Result.new(self, outcome)
    end

  end

end
