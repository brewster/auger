require "net/http"

module Auger

  class Project
    def http(port, &block)
      @connections << Http.load(port, &block)
    end
    
    def https(port, &block)
      http = Http.load(port, &block)
      http.ssl(true)
      @connections << http
    end

  end

  class Http < Auger::Connection
    #attr_accessor :url, :requests, :ssl, :insecure, :user, :password
    attr_accessor :url, :ssl, :insecure, :user, :password

    def initialize(port)
      @headers = []
      super
    end

    def url(*u)
      u.empty? ? @url : @url = u.join('')
    end

    def user(user)
      @user = user
    end

    def password(password)
      @password = password
    end

    def get(url, &block)
      @url = url
      @requests << Auger::HttpRequest.load(url, &block)
    end

    def connect(host)
      Net::HTTP.new(host, @port)
    end

    def ssl(flag)
      @ssl = flag
    end

    def insecure(flag)
      @insecure = flag
    end

    def do_requests(host)
      http = Net::HTTP.new(host, @port)
      http.use_ssl = @ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @insecure
      http.basic_auth(@user, @password||'') if @user
      @headers.each do |header|
        key, value = header.split /\s*:\s*/
        http[key] = value
      end
      http.start do |http|
        @requests.each do |request|
          get = Net::HTTP::Get.new(request.arg)
          request.headers.each { |k,v| get[k] = v }
          request.response = http.request(get)
        end
      end
    end

  end

  class HttpRequest < Auger::Request
    attr_accessor :headers

    def initialize(url)
      @headers = {}
      super
    end

    ## treat all methods as setters for http headers
    def header(h)
      key, value = h.split /\s*:\s*/
      @headers[key] = value
    end
  end

end
