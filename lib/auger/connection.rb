module Auger

  class Connection
    attr_accessor :port, :requests, :connection, :response, :roles

    def self.load(port, &block)
      connection = new(port)
      connection.instance_eval(&block)
      connection
    end

    def initialize(port)
      @port = port
      @roles = []
      @requests = []
    end

    def roles(*names)
      @roles += names if names
      @roles
    end

    def do_requests(host)
      begin
        conn = self.open(host)
        @requests.each do |request|
          request.response = request.run(conn) rescue $!
        end
        self.close conn
      rescue => e
        @requests.each do |request|
          request.response = e  # response can be an Exception if we caught one
        end
      end
    end

  end
  
end
