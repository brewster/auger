require 'cassandra'

module Auger

  class Project
    def cassandra(port = 9160, &block)
      @connections << Cassandra.load(port, &block)
    end
  end

  class Cassandra < Auger::Connection
    def open(host, options)
      ::Cassandra.new(options[:keyspace], "#{host}:#{options[:port]}")
    end

    def close(cassandra)
      cassandra.disconnect!
    end

    def cluster_name(&block)
      @requests << Class.new(Auger::Request) do
        def run(cassandra)
          cassandra.cluster_name
        end
      end.load(nil, &block)
    end

    def ring(&block)
      @requests << Class.new(Auger::Request) do
        def run(cassandra)
          cassandra.ring
        end
      end.load(nil, &block)
    end

    def schema_agreement?(&block)
      @requests << Class.new(Auger::Request) do
        def run(cassandra)
          cassandra.schema_agreement?
        end
      end.load(nil, &block)
    end

  end

end
