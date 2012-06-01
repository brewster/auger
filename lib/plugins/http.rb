require "net/http"

module Auger

  class Project
    def http(port = 80, &block)
      @connections << Http.load(port, &block)
    end
    
    def https(port = 443, &block)
      http = Http.load(port, &block)
      http.ssl(true)
      @connections << http
    end

  end

  class Http < Auger::Connection
    def get(url, &block)
      @url = url
      @requests << Auger::HttpRequest.load(url, &block)
    end

    def open(host)
      http = Net::HTTP.new(host, @options[:port])
      http.use_ssl = @options[:ssl]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @options[:insecure]
      http.start
      http
    end

    def close(http)
      http.finish
    end

  end

  class HttpRequest < Auger::Request
    attr_accessor :headers, :user, :password

    def initialize(url)
      @headers = {}
      super
    end

    def header(h)
      key, value = h.split /\s*:\s*/
      @headers[key] = value
    end

    def user(user)
      @user = user
    end

    def password(password)
      @password = password
    end

    def run(http)
      get = Net::HTTP::Get.new(@arg)
      get.basic_auth(@user, @password||'') if @user
      @headers.each { |k,v| get[k] = v }
      http.request(get)
    end

  end

end
