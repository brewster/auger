## HTTP plugin for auger; requests look like this:
##
##   http 80 do
##
##     get "/foo" do
##       header "User-Agent: AugerExample/1.0"
##       test "HTTP Status Code" do |r|
##         Result r.code, r.code == 200
##       end
##     end
##
##     post "/bar" do
##       data :a => "hello", :b => "world"
##       test "POST request body" do |r|
##         r.body
##       end
##     end
##
##   end

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
      @requests << Auger::HttpGet.load(url, &block)
    end

    def post(url, &block)
      @requests << Auger::HttpPost.load(url, &block)
    end

    def open(host, options)
      http = Net::HTTP.new(host, options[:port])
      http.use_ssl = options[:ssl]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if options[:insecure]
      http.open_timeout = options[:timeout]
      http.read_timeout = options[:timeout]
      http.start
      http
    end

    def close(http)
      http.finish
    end

  end

  class HttpRequest < Auger::Request
    attr_accessor :method, :headers, :user, :password, :data
    alias_method :url, :arg

    def initialize(url)
      @method ||= :get          # default
      @headers = {}
      @data = {}
      super
    end

    def data(hash)
      @data = hash
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

    def run(http, url)
      request = Net::HTTP::const_get(@method.capitalize).new(url) # e.g. Net::HTTP::Get
      request.basic_auth(@user, @password || '') if @user
      @headers.each { |k,v| request[k] = v }
      request.set_form_data(@data)
      http.request(request)
    end

  end

  class HttpGet < Auger::HttpRequest
    def initialize(url)
      @method = :get
      super
    end
  end

  class HttpPost < Auger::HttpRequest
    def initialize(url)
      @method = :post
      super
    end
  end

end
