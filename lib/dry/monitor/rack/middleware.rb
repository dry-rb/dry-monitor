require 'rack/utils'

module Dry
  module Monitor
    module Rack
      class Middleware
        REQUEST_START = :'rack.request.start'
        REQUEST_STOP = :'rack.request.stop'
        REQUEST_ERROR = :'rack.request.error'

        attr_reader :app
        attr_reader :notifications

        def initialize(*args)
          @notifications, @app = *args

          notifications.event(REQUEST_START)
          notifications.event(REQUEST_STOP)
          notifications.event(REQUEST_ERROR)
        end

        def new(app)
          self.class.new(notifications, app)
        end

        def on(event_id, &block)
          notifications.subscribe(:"rack.request.#{event_id}", &block)
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
