require 'cassandra-cql'

module Auger
  
  class Project
    def cql(port = 9160, &block)
      @connections << Cql.load(port, &block)
    end
  end

  class Cql < Auger::Connection
    attr_accessor :options

    def initialize(port)
      @options = {}
      super
    end

    def keyspace(keyspace)
      @options[:keyspace] = keyspace
    end

    def execute(statement, &block)
      @requests << CqlRequest.load(statement, &block)
    end

    def open(host)
      CassandraCQL::Database.new "#{host}:#{@port}", @options
    end

    def close(db)
      db.disconnect!
    end
    
  end

  class CqlRequest < Auger::Request
    def run(db)
      db.execute(@arg)
    end
  end

end