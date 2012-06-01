require 'net/dns'

module Auger

  class Project
    def dns(port = 53, &block)
      @connections << Dns.load(port, &block)
    end
  end
  
  class Dns < Auger::Connection
    def domain(&block)
      @requests << DnsDomainRequest.load(nil, &block)
    end

    def open(host, options)
      options[:nameserver] = host
      dns = Net::DNS::Resolver.new(options)
      dns.use_tcp = true if options[:use_tcp]
      dns
    end

    def close(dns)
      dns = nil
    end

    def query(name, &block)
      @requests << DnsQueryRequest.load(name, &block)
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
