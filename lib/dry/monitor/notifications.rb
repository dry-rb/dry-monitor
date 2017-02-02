module Dry
  module Monitor
    class Clock
      def measure(&block)
        start = current
        result = block.()
        stop = current
        [result, ((stop - start) * 1000).round(2)]
      end

      def current
        Time.now
      end
    end

    CLOCK = Clock.new

    class Event
      attr_reader :id

      attr_reader :info

      def initialize(id, info = {})
        @id = id
        @info = info
      end
    end

    class Notifications
      attr_reader :id
      attr_reader :events
      attr_reader :listeners
      attr_reader :clock

      def initialize(id)
        @id = id
        @listeners = Hash.new { |h, k| h[k] = [] }
        @events = {}
        @clock = CLOCK
      end

      def event(id, info = {})
        events[id] = Event.new(id, info) unless events.key?(id)
        self
      end

      def subscribe(event_id, listener = nil, &block)
        listeners[event_id] << (listener || block)
        self
      end

      def start(event_id, payload)
        instrument(event_id, payload)
      end

      def stop(event_id, payload)
        instrument(event_id, payload)
      end

      def instrument(event_id, payload = nil, &block)
        event = events[event_id]

        if block
          result, time = clock.measure(&block)
        end

        listeners[event_id].each do |listener|
          if time
            listener.(time, event.id, payload.merge(event.info))
          else
            listener.(event.id, payload.merge(event.info))
          end
        end

        result
      end
    end
  end
end
