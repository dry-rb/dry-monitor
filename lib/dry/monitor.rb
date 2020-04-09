# frozen_string_literal: true

require "dry/monitor/logger"
require "dry/monitor/notifications"
require "dry/core/extensions"

module Dry
  module Monitor
    extend Dry::Core::Extensions

    register_extension(:rack) do
      require "rack/utils"
      require "dry/monitor/rack/logger"
    end

    register_extension(:sql) do
      require "dry/monitor/sql/logger"
    end
  end
end
