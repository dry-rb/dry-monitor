require 'dry-configurable'
require 'rouge'

module Dry
  module Monitor
    module SQL
      class Logger
        extend Dry::Configurable

        setting :theme, Rouge::Themes::Gruvbox
        setting :colorize, true

        attr_reader :config
        attr_reader :logger
        attr_reader :formatter
        attr_reader :lexer

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
          @formatter = Rouge::Formatters::Terminal256.new(config.theme)
          @lexer = Rouge::Lexers::SQL.new
        end

        def subscribe(notifications)
          notifications.event(:sql).subscribe(:sql) do |time, id, payload|
            log_query(time, payload[:name], payload[:query])
          end
        end

        def log_query(time, name, query)
          logger.info "  Loaded #{name.inspect} in #{time}ms #{colorize(query)}"
        end

        private

        def colorize(string)
          config.colorize ? formatter.format(lexer.lex(string)) : string
        end
      end
    end
  end
end
