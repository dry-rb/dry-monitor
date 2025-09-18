# frozen_string_literal: true

module Dry
  module Monitor
    module SQL
      module Colorizers
        class Default
          def initialize(_theme); end
          # rubocop:enable Style/RedundantInitialize

          def call(string)
            string
          end
        end
      end
    end
  end
end
