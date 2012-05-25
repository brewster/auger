require 'net/dns'

module Auger

  class Project
    def dns(port = 53, &block)
      @connections << Dns.load(port, &block)
    end
  end
  
  class Dns < Auger::Connection
    attr_accessor :options, :use_tcp

    def initialize(port)
      @options = {}
      super
    end

    ## use TCP virtual circuits instead of UDP datagrams
    def use_tcp(bool)
      @use_tcp = bool
    end

    def domain(&block)
      @requests << DnsDomainRequest.load(nil, &block)
    end

    def query(name, &block)
      @requests << DnsQueryRequest.load(name, &block)
    end

    def open(host)
      @options[:nameserver] = host
      @options[:port] = @port
      dns = Net::DNS::Resolver.new(@options)
      dns.use_tcp = true if @use_tcp
      dns
    end

    def close(dns)
      dns = nil
    end

  end

  class DnsDomainRequest < Auger::Request
    def run(dns)
      dns.domain
    end
  end
  
  class DnsQueryRequest < Auger::Request
    def run(dns)
      dns.query(@arg)
    end
  end

end
