require 'net/telnet'

module Auger
  class Project
    def telnet(port = 23, &block)
      @connections << Telnet.load(port, &block)
    end
  end

  class Telnet < Auger::Connection
    attr_accessor :options

    def initialize(port)
      @options = { "Port" => port }
      super
    end

    def cmd(arg, &block)
      @requests << TelnetRequest.load(arg, &block)
    end

    def timeout(value)
      @options["Timeout"] = value.to_i
    end

    def binmode(bool)
      @options["Binmode"] = bool
    end

    def open(host)
      opts = @options.merge("Host" => host)
      Net::Telnet::new(opts)
    end

    def close(telnet)
      telnet.close
    end

    def do_requests(host)
      opts = @options.merge("Host" => host)
      telnet = Net::Telnet::new(opts)
      @requests.each do |request|
        request.response = telnet.cmd(request.arg)
      end
      telnet.close
    end
  end

  class TelnetRequest < Auger::Request
    def run(telnet)
      telnet.cmd(@arg)
    end
  end

end
