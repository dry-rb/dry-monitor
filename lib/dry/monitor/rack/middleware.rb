# frozen_string_literal: true

require 'dry/monitor/notifications'

module Dry
  module Monitor
    module Rack
      class Middleware
        REQUEST_START = :'rack.request.start'
        REQUEST_STOP = :'rack.request.stop'
        REQUEST_ERROR = :'rack.request.error'

        Notifications.register_event(REQUEST_START)
        Notifications.register_event(REQUEST_STOP)
        Notifications.register_event(REQUEST_ERROR)

        attr_reader :app

        attr_reader :notifications

        def initialize(*args)
          @notifications, @app = *args
        end

        def new(app, *_args, &_block)
          self.class.new(notifications, app)
        end

        def on(event_id, &block)
          notifications.subscribe(:"rack.request.#{event_id}", &block)
        end

        def instrument(event_id, *args, &block)
          notifications.instrument(:"rack.request.#{event_id}", *args, &block)
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
