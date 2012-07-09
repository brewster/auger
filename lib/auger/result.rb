module Auger

  class Result
    attr_accessor :test, :outcome, :status, :time

    def initialize(outcome = nil, status = outcome)
      @outcome = outcome
      @status  = status
    end

  end

end
