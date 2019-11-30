# frozen_string_literal: true

if ENV['COVERAGE'].eql?('true')
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

begin
  require 'byebug'
rescue LoadError; end
require 'dry-monitor'
Dry::Monitor.load_extensions(:sql, :rack)

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('support/**/*.rb')].each(&method(:require))

RSpec.configure(&:disable_monkey_patching!)
