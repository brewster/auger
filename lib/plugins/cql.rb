require 'cassandra-cql'

module Auger
  
  class Project
    def cql(port, &block)
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
      @requests << Auger::Request.load(statement, &block)
    end

    def do_requests(host)
      db = CassandraCQL::Database.new "#{host}:#{@port}", @options
      @requests.each do |request|
        request.response = db.execute(request.arg)
      end
      db.disconnect!
    end
    
  end

end
