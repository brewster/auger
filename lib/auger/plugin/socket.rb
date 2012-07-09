require 'socket'

module Auger
  class Project
    def socket(port, &block)
      @connections << Socket.load(port, &block)
    end
  end

  class Socket < Auger::Connection
    def open(host, options)
      TCPSocket.open(host, options[:port]) rescue false
    end

    def close(socket)
      socket.close if socket
    end

    def open?(&block)
      @requests << SocketRequest.load(nil, &block)
    end
  end

  class SocketRequest < Auger::Request
    def run(socket, arg)
      socket ? true : false      
    end
  end

end
