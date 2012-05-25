module Auger
  
  class Result
    attr_accessor :test, :outcome
    def initialize(test, outcome)
      @test = test
      @outcome = outcome
    end
    
    # def to_s
    #   case @outcome
    #   when MatchData then
    #     @outcome.captures.empty? ? "\u2713" : @outcome.captures.join(' ')
    #   when TrueClass then
    #     "\u2713"
    #   when FalseClass then
    #     "\u2717"
    #   when NilClass then
    #     "\u2717"
    #   else
    #     @outcome.to_s
    #   end
    # end

  end

end
