# frozen_string_literal: true

require "bundler/setup"

require_relative "support/coverage"

begin
  require "byebug"
rescue LoadError; end
require "dry-monitor"
Dry::Monitor.load_extensions(:sql, :rack)

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join("shared/**/*.rb")].sort.each(&method(:require))
Dir[SPEC_ROOT.join("support/**/*.rb")].sort.each(&method(:require))

Warning.ignore(/rouge/)

RSpec.configure(&:disable_monkey_patching!)
