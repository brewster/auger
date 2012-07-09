require 'net/telnet'

module Auger
  class Project
    def telnet(port = 23, &block)
      @connections << Telnet.load(port, &block)
    end
  end

  class Telnet < Auger::Connection
    def timeout(value)
      @options[:timeout] = value.to_i
    end

    def open(host, options)
      ## telnet opts array needs capitalized strings as keys
      opts = { 'Host' => host }
      options.each { |key, value| opts[key.to_s.capitalize] = value }
      Net::Telnet::new(opts)
    end

    def close(telnet)
      telnet.close
    end

    def cmd(arg, &block)
      @requests << TelnetRequest.load(arg, &block)
    end
  end

  class TelnetRequest < Auger::Request
    def run(telnet, arg)
      telnet.cmd(arg)
    end
  end

end
