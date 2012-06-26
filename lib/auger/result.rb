module Auger

  class Result
    attr_accessor :test, :outcome, :status

    def initialize(outcome = nil, status = outcome)
      @outcome = outcome
      @status  = status
    end

  end

end
