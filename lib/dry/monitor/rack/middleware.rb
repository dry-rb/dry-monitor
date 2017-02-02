require 'rack/utils'

module Dry
  module Monitor
    module Rack
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
