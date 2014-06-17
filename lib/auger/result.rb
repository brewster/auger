module Auger

  class Result
    attr_accessor :test, :outcome, :status, :time

    def initialize(outcome = nil, status = outcome)
      @outcome = outcome
      @status  = status
    end

    def format
      output =
        case self.outcome
        when TrueClass  then "\u2713"
        when MatchData  then outcome.captures.empty? ? "\u2713" : outcome.captures.join(' ')
        when FalseClass then puts "false"; "\u2717"
        when NilClass   then puts "nillly"; "nil"
        when Exception
          "#{outcome.class}: #{outcome.to_s}" +
          "\n\tBacktrace:\n\t#{outcome.backtrace.join("\n\t")}"
        else                 outcome.to_s
        end

      color =
        case self.status
        when FalseClass, NilClass then :red
        when Exception            then :magenta
        when Status               then
          case self.status.value
            when :ok        then :green
            when :warn      then :yellow
            when :exception then :magenta
          else                   :red
          end
        else                           :green
        end

      return output.color(color)
    end

    def verbose?
      !!AUGER_OPS[:verbose]
    end
  end
end
