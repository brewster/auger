module Auger

  class Config
    attr_accessor :projects
    def self.load(filename)
      config = new
      config.instance_eval(File.read(filename), filename)
      config
    end

    def initialize
      @projects = []
      self
    end

    def project(name, &block)
      @projects << Project.load(name, &block)
    end
  end
end
