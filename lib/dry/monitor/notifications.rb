# frozen_string_literal: true

require "dry/events/publisher"
require "dry/monitor/constants"

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
      include Events::Publisher["Dry::Monitor::Notifications"]

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
        result, time = @clock.measure { yield payload } if block_given?
      # We should always try to instrument, even the system-level exceptions
      rescue Exception => e # rubocop:disable Lint/RescueException
        payload = {} if payload.equal?(EMPTY_HASH)
        payload[:exception] = e
        raise
      ensure
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
