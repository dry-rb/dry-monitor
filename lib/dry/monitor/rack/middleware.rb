require 'dry/configurable'
require 'rack/utils'

module Dry
  module Monitor
    module Rack
      class Logger
        extend Dry::Configurable

        setting :filtered_params, %w[_csrf password]

        REQUEST_METHOD = 'REQUEST_METHOD'.freeze
        PATH_INFO = 'PATH_INFO'.freeze
        REMOTE_ADDR = 'REMOTE_ADDR'.freeze
        RACK_INPUT = 'rack.input'.freeze
        QUERY_PARAMS = 'QUERY_PARAMS'.freeze

        START_MSG = %(Started %s "%s" for %s at %s).freeze
        STOP_MSG = %(Finished %s "%s" for %s in %sms [Status: %s]).freeze
        PARAMS_MSG = %(  Parameters %s).freeze
        QUERY_MSG = %(  Query parameters %s).freeze
        FILTERED = '[FILTERED]'.freeze

        attr_reader :logger

        attr_reader :config

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
        end

        def subscribe(notifications)
          notifications.subscribe(Middleware::REQUEST_START) do |id, payload|
            log_start_request(payload[:env])
          end

          notifications.subscribe(Middleware::REQUEST_STOP) do |id, payload|
            log_stop_request(payload[:env], payload[:status], payload[:time])
          end

          notifications.subscribe(Middleware::APP_ERROR) do |id, payload|
            log_exception(payload[:exception], payload[:name])
          end
        end

        def log_exception(e, app_name)
          logger.error e.message
          logger.error filter_backtrace(e.backtrace, app_name).join("\n")
        end

        def log_start_request(request)
          info START_MSG % [
                 request[REQUEST_METHOD],
                 request[PATH_INFO],
                 request[REMOTE_ADDR],
                 Time.now
               ]
          log_request_params(request)
        end

        def log_stop_request(request, status, time)
          info STOP_MSG % [
                 request[REQUEST_METHOD],
                 request[PATH_INFO],
                 request[REMOTE_ADDR],
                 time,
                 status
               ]
        end

        def log_request_params(request)
          with_http_params(request[QUERY_PARAMS]) do |params|
            info QUERY_MSG % [params.inspect]
          end
        end

        def info(*args)
          logger.info(*args)
        end

        def with_http_params(params)
          params = ::Rack::Utils.parse_nested_query(params)
          if params.size > 0
            yield(filter_params(params))
          end
        end

        def filter_backtrace(backtrace, app_name)
          # TODO: what do we want to do with this?
          backtrace.reject { |l| l.include?('gems') }
        end

        def filter_params(params)
          params.each_with_object({}) do |(k, v), h|
            if v.is_a?(Hash)
              h.update(k => filter_params(v))
            elsif v.is_a?(Array)
              h.update(k => v.map { |m| filter_params(m) })
            elsif config.filtered_params.include?(k)
              h.update(k => FILTERED)
            else
              h[k] = v
            end
          end
        end
      end

      class Middleware
        REQUEST_START = :'request.start'
        REQUEST_STOP = :'request.stop'
        APP_ERROR = :'app.error'

        attr_reader :app
        attr_reader :notifications

        def initialize(*args)
          @notifications, @app = *args

          notifications.event(REQUEST_START)
          notifications.event(REQUEST_STOP)
          notifications.event(APP_ERROR)
        end

        def new(app)
          self.class.new(notifications, app)
        end

        def call(env)
          notifications.start(REQUEST_START, env: env)
          response, time = CLOCK.measure { app.call(env) }
          notifications.stop(REQUEST_STOP, env: env, time: time, status: response[0])
          response
        end
      end
    end
  end
end
