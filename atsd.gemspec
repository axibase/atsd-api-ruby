# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atsd/version'

Gem::Specification.new do |spec|
  spec.name          = 'atsd'
  spec.version       = ATSD::VERSION
  spec.license       = 'Apache-2.0'
  spec.authors       = ['Axibase Corporation']
  spec.email         = ['atsd-api@axibase.com']

  spec.summary       = %q{Axibase Time Series Database Client for Ruby.}
  spec.description   = %q{Axibase Time Series Database Client for Ruby is an easy-to-use client for interfacing with ATSD metadata and data REST API services.}
  spec.homepage      = 'https://github.com/axibase/atsd-api-ruby/'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'yard', '~> 0.9.11'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'geminabox'
  spec.add_development_dependency 'multi_json'

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'
  spec.add_dependency 'hashie', '~> 3.4'
  spec.add_dependency 'activesupport', '~> 4.0'
end
