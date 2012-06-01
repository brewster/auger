require 'cassandra-cql'

module Auger
  
  class Project
    def cql(port = 9160, &block)
      @connections << Cql.load(port, &block)
    end
  end

  class Cql < Auger::Connection
    def open(host, options)
      CassandraCQL::Database.new "#{host}:#{options[:port]}", options
    end

    def close(db)
      db.disconnect!
    end

    def execute(statement, &block)
      @requests << CqlRequest.load(statement, &block)
    end
  end

  class CqlRequest < Auger::Request
    def run(db)
      db.execute(@arg)
    end
  end

end
