require 'net/telnet'

module Auger
  class Project
    def telnet(port, &block)
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
      @requests << Auger::Request.load(arg, &block)
    end

    def timeout(value)
      @options["Timeout"] = value.to_i
    end

    def binmode(bool)
      @options["Binmode"] = bool
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

end
