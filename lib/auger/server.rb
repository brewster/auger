module Auger

  class Server
    attr_accessor :name, :options, :roles

    def initialize(name, *args)
      @name = name
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @roles = args
    end

  end

end
