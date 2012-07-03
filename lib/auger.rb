require 'auger/version'
require 'auger/config'
require 'auger/project'
require 'auger/server'
require 'auger/connection'
require 'auger/request'
require 'auger/test'
require 'auger/result'
require 'auger/status'

## plugins
require 'auger/plugin/dns.rb'
require 'auger/plugin/http.rb'
require 'auger/plugin/redis.rb'
require 'auger/plugin/socket.rb'
require 'auger/plugin/telnet.rb'

module Auger
  ##
end
