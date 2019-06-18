# frozen_string_literal: true

require 'dry-configurable'
require 'dry/core/extensions'
require 'dry/monitor/notifications'

module Dry
  module Monitor
    Notifications.register_event(:sql)

    module SQL
      class Logger
        extend Dry::Core::Extensions
        extend Dry::Configurable

        register_extension(:default_colorizer) do
          require_relative './colorizers/default'

          def colorizer
            @colorizer ||= Colorizers::Default.new(config.theme)
          end
        end

        register_extension(:rouge_colorizer) do
          require_relative './colorizers/rouge'

          def colorizer
            @colorizer ||= Colorizers::Rouge.new(config.theme)
          end
        end

        setting :theme, nil
        setting :message_template, %(  Loaded %s in %sms %s)

        attr_reader :config
        attr_reader :logger
        attr_reader :template

        load_extensions(:default_colorizer)

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
          @template = config.message_template
        end

        def subscribe(notifications)
          notifications.subscribe(:sql) do |time:, name:, query:|
            log_query(time, name, query)
          end
        end

        def log_query(time, name, query)
          logger.info template % [name.inspect, time, colorizer.call(query)]
        end
      end
    end
  end
end
