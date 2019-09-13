# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord-jdbcvertica-adapter/version'

Gem::Specification.new do |gem|
  gem.name          = "activerecord-jdbcvertica-adapter"
  gem.version       = Activerecord::Jdbcvertica::Adapter::VERSION
  gem.authors       = ["Brandon Dewitt"]
  gem.email         = ["brandonsdewitt@gmail.com"]
  gem.description   = %q{ An ActiveRecord adapter for Vertica databases (jdbc based) }
  gem.summary       = %q{ An ActiveRecord adapter JDBC }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.licenses      = [ "MIT" ]

  gem.add_dependency "activerecord", "4.2.11.1"
  gem.add_dependency "activerecord-jdbc-adapter", "< 50"

  gem.add_development_dependency "bundler", "1.17.3"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"
end
