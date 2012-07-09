#require 'redis/connection'
require 'redis'

module Auger

  class Project
    def redis(port = 6379, &block)
      @connections << Auger::Redis.load(port, &block)
    end
  end

  class Redis < Auger::Connection
    def open(host, options)
      ::Redis.new options.merge({:host => host, :thread_safe => true, :port => options[:port]})
    end

    def close(redis)
      redis.quit
    end

    def ping(&block)
      @requests << Auger::RedisPing.load(nil, &block)
    end

    def info(&block)
      @requests << Auger::RedisInfo.load(nil, &block)
    end

    def dbsize(&block)
      @requests << Auger::RedisDbsize.load(nil, &block)
    end

    def get(key, &block)
      @requests << Auger::RedisGet.load(key, &block)
    end

    def exists(key, &block)
      @requests << Auger::RedisExists.load(key, &block)
    end

  end

  class RedisPing < Auger::Request
    def run(redis, arg)
      redis.ping
    end
  end

  class RedisInfo < Auger::Request
    def run(redis, arg)
      redis.info
    end
  end

  class RedisDbsize < Auger::Request
    def run(redis, arg)
      redis.dbsize
    end
  end

  class RedisGet < Auger::Request
    def run(redis, arg)
      redis.get(arg)
    end
  end

  class RedisExists < Auger::Request
    def run(redis, arg)
      redis.exists(arg)
    end
  end

end
