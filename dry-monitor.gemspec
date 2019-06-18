# frozen_string_literal: true

require File.expand_path('lib/dry/monitor/version', __dir__)

Gem::Specification.new do |spec|
  spec.name          = 'dry-monitor'
  spec.version       = Dry::Monitor::VERSION
  spec.authors       = ['Piotr Solnica']
  spec.email         = ['piotr.solnica@gmail.com']
  spec.summary       = 'Monitoring and instrumentation APIs'
  spec.homepage      = 'https://github.com/dry-rb/dry-monitor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-configurable', '~> 0.5'
  spec.add_runtime_dependency 'dry-core', '~> 0.4'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-events', '~> 0.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rouge', '~> 2.0', '>= 2.2.1'
  spec.add_development_dependency 'rspec'
end
