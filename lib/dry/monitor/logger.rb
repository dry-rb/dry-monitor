require 'logger'

module Dry
  module Monitor
    class Logger < ::Logger
      def initialize(*args)
        super
        self.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end
    end
  end
end
