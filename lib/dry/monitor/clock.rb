# frozen_string_literal: true

module Dry
  module Monitor
    # @api public
    class Clock
      # @api public
      def measure
        start = current
        result = yield
        [result, current - start]
      end

      # @api public
      def current
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      end
    end
  end
end
