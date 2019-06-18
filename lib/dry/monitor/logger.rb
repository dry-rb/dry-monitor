# frozen_string_literal: true

require 'logger'

module Dry
  module Monitor
    class Logger < ::Logger
      def initialize(*args)
        super
        self.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end
    end
  end
end
