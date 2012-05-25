module Auger
  
  class Test
    attr_accessor :name, :block
    def initialize(name, block)
      @name = name
      @block = block
    end
    
    ## you can call test with no block if you just want to return response value
    def run(response)
      @block ? @block.call(response) : response
    end

  end

end
