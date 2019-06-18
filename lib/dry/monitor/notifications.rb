require 'dry/events/publisher'
require 'dry/core/constants'

module Dry
  module Monitor
    class Clock
      def measure
        start = current
        result = yield
        [result, current - start]
      end

      def current
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      end
    end

    CLOCK = Clock.new

    class Notifications
      include Events::Publisher['Dry::Monitor::Notifications']
      include Dry::Core::Constants

      attr_reader :id

      attr_reader :clock

      def initialize(id)
        @id = id
        @clock = CLOCK
      end

      def start(event_id, payload)
        instrument(event_id, payload)
      end

      def stop(event_id, payload)
        instrument(event_id, payload)
      end

      def instrument(event_id, payload = EMPTY_HASH)
        if block_given?
          result, time = @clock.measure { yield }
        end

        process(event_id, payload) do |event, listener|
          if time
            listener.(event.payload(payload.merge(time: time)))
          else
            listener.(event)
          end
        end

        result
      end
    end
  end
end
