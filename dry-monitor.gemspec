# coding: utf-8
require File.expand_path('../lib/dry/monitor/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'dry-logic'
  spec.version       = Dry::Monitor::VERSION
  spec.authors       = ['Piotr Solnica']
  spec.email         = ['piotr.solnica@gmail.com']
  spec.summary       = 'Monitoring and instrumentation APIs'
  spec.homepage      = 'https://github.com/dryrb/dry-logic'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
