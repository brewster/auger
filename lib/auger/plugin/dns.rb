require 'net/dns'

module Auger

  class Project
    def dns(port = 53, &block)
      @connections << Dns.load(port, &block)
    end
  end
  
  class Dns < Auger::Connection
    def open(host, options)
      options[:nameserver] = host
      ## resolver checks args and raises error if no matching method, so only pass valid options
      safe_options = options.select{ |key| Net::DNS::Resolver.method_defined? key }
      dns = Net::DNS::Resolver.new(safe_options)
      dns.use_tcp = true if options[:use_tcp]
      dns
    end

    def close(dns)
      dns = nil
    end

    def domain(&block)
      @requests << DnsDomainRequest.load(nil, &block)
    end

    def query(name, &block)
      @requests << DnsQueryRequest.load(name, &block)
    end
  end

  class DnsDomainRequest < Auger::Request
    def run(dns, ignored_arg)
      dns.domain
    end
  end
  
  class DnsQueryRequest < Auger::Request
    def run(dns, ignored_arg)
      dns.query(@arg)
    end
  end

end
