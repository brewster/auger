# -*- encoding: utf-8 -*-
require File.expand_path('../lib/auger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ric Lister", "Grant Heffernan"]
  gem.email         = ["ric@brewster.com", "grant@brewster.com"]
  gem.description   = %q{Auger let's you write tests to verify expected behaviors from all your applications}
  gem.summary       = %q{App && infrastructure testing DSL}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "auger"
  gem.require_paths = ["lib"]
  gem.version       = Auger::VERSION

  # dependencies
  gem.add_dependency('json')
  gem.add_dependency('net-dns')
  gem.add_dependency('rainbow')
  gem.add_dependency('host_range')
  gem.add_dependency('cassandra-cql')
end
