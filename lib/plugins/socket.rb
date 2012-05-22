require 'socket'

module Auger
  class Project
    def socket(port, &block)
      @connections << Socket.load(port, &block)
    end
  end

  class Socket < Auger::Connection
    def open?(&block)
      @requests << Auger::Request.load(nil, &block)
    end

    def do_requests(host)
      ## hack, just return false if the socket fails to connect
      socket = begin
                 TCPSocket.open(host, @port)
               rescue
                 false
               end
      @requests.each do |request|
        request.response = socket ? true : false
      end
      socket.close if socket
    end

  end

end
