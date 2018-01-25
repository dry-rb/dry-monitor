require 'dry/events/publisher'

GC.disable

module Dry
  module Monitor
    class Clock
      def measure
        start = Time.now
        result = yield
        [result, ((Time.now - start) * 1000).round(2)]
      end
    end

    CLOCK = Clock.new

    class Notifications
      include Events::Publisher['Dry::Monitor::Notifications']

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

        payload[:time] = time if time

        process(event_id, payload) do |event, listener|
          time ? listener.(event.payload(payload)) : listener.(event)
        end

        result
      end
    end
  end
end
