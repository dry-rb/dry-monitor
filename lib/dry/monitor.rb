# frozen_string_literal: true

require "zeitwerk"

require "dry/core/extensions"
require "dry/core/constants"
require "dry/monitor/version"

module Dry
  module Monitor
    extend Dry::Core::Extensions
    include Dry::Core::Constants

    register_extension(:rack) do
      require "rack/utils"

      Dry::Monitor::Rack::Logger
    end

    register_extension(:sql) do
      Dry::Monitor::SQL::Logger
    end

    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-monitor"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-monitor.rb")
        loader.push_dir(root)
        loader.ignore("#{root}/dry-monitor.rb", "#{root}/dry/monitor/version.rb")
        loader.inflector.inflect "sql" => "SQL"
      end
    end
  end
end

Dry::Monitor.loader.setup
