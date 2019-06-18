# frozen_string_literal: true

require 'dry/configurable'
require 'dry/monitor/rack/middleware'

module Dry
  module Monitor
    module Rack
      class Logger
        extend Dry::Configurable

        setting :filtered_params, %w[_csrf password]

        REQUEST_METHOD = 'REQUEST_METHOD'
        PATH_INFO = 'PATH_INFO'
        REMOTE_ADDR = 'REMOTE_ADDR'
        QUERY_STRING = 'QUERY_STRING'

        START_MSG = %(Started %s "%s" for %s at %s)
        STOP_MSG = %(Finished %s "%s" for %s in %sms [Status: %s]\n)
        QUERY_MSG = %(  Query parameters %s)
        FILTERED = '[FILTERED]'

        attr_reader :logger

        attr_reader :config

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
        end

        def attach(rack_monitor)
          rack_monitor.on(:start) do |env:|
            log_start_request(env)
          end

          rack_monitor.on(:stop) do |env:, status:, time:|
            log_stop_request(env, status, time)
          end

          rack_monitor.on(:error) do |event|
            log_exception(event[:exception])
          end
        end

        def log_exception(err)
          logger.error err.message
          logger.error filter_backtrace(err.backtrace).join("\n")
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
          with_http_params(request[QUERY_STRING]) do |params|
            info QUERY_MSG % [params.inspect]
          end
        end

        def info(*args)
          logger.info(*args)
        end

        def with_http_params(params)
          params = ::Rack::Utils.parse_nested_query(params)

          yield(filter_params(params)) unless params.empty?
        end

        def filter_backtrace(backtrace)
          # TODO: what do we want to do with this?
          backtrace.reject { |l| l.include?('gems') }
        end

        def filter_params(params)
          params.each_with_object({}) do |(k, v), h|
            if config.filtered_params.include?(k)
              h.update(k => FILTERED)
            elsif v.is_a?(Hash)
              h.update(k => filter_params(v))
            elsif v.is_a?(Array)
              h.update(k => v.map { |m| m.is_a?(Hash) ? filter_params(m) : m })
            else
              h[k] = v
            end
          end
        end
      end
    end
  end
end
