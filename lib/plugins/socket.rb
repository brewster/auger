require 'socket'

module Auger
  class Project
    def socket(port, &block)
      @connections << Socket.load(port, &block)
    end
  end

  class Socket < Auger::Connection
    def open?(&block)
      @requests << SocketRequest.load(nil, &block)
    end

    def open(host)
      TCPSocket.open(host, @port) rescue false
    end

    def close(socket)
      socket.close if socket
    end

  end

  class SocketRequest < Auger::Request
    def run(socket)
      socket ? true : false      
    end
  end

end
