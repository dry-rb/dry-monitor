require 'dry/monitor/logger'
require 'dry/monitor/notifications'
require 'dry/monitor/rack/middleware'
require 'dry/monitor/rack/logger'
require 'dry/core/extensions'

module Dry
  module Monitor
    extend Dry::Core::Extensions

    register_extension(:sql) do
      require 'dry/monitor/sql/logger'
    end
  end
end
