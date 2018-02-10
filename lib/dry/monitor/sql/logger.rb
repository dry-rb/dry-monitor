require 'dry-configurable'
require 'dry/monitor/notifications'
require 'dry/monitor/sql/colorize'

module Dry
  module Monitor
    Notifications.register_event(:sql)

    module SQL
      class Logger
        extend Dry::Configurable

        setting :theme, nil
        setting :colorize, true
        setting :message_template, %(  Loaded %s in %sms %s).freeze

        attr_reader :config
        attr_reader :logger
        attr_reader :template

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
          @template = config.message_template
          @colorize = Colorize.new(config.theme)
        end

        def subscribe(notifications)
          notifications.subscribe(:sql) do |time:, name:, query:|
            log_query(time, name, query)
          end
        end

        def log_query(time, name, query)
          logger.info template % [name.inspect, time, colorize(query)]
        end

        private

        def colorize(string)
          config.colorize ? @colorize.call(string) : string
        end
      end
    end
  end
end
