# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
  
Gem::Specification.new do |s|
  s. name        = "auger"
  s. version     = "0.0.1"
  s. platform    = Gem::Platform::RUBY
  s. authors     = ["Ric Lister"]
  s. email       = ["ric@brewster.com"]
  s. summary     = "Drill down... deep"
  s. description = "Auger is a DSL which let's your write tests to confirm the condition of your applications and infrastructure"
                 
  s. files        = Dir.glob("{bin,lib,cfg}/**/*") + %w(README.md Gemfile Gemfile.lock)
  s. executables  = ['aug']
  s. require_path = 'lib'
end
