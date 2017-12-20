require 'spec_helper'

RSpec.describe 'Subscribing to instrumentation events' do
  subject(:notifications) { Dry::Monitor::Notifications.new(:app) }

  before do
    Dry::Monitor::Notifications.register_event(:sql, { name: 'rom[sql]' })
  end

  describe '#instrument' do
    it 'allows subscribing via block' do
      captured = []
      payload = { query: 'SELECT 1 FROM users' }

      notifications.subscribe(:sql) do |event|
        captured << [event.id, event[:query]]
      end

      notifications.instrument(:sql, payload)

      expect(captured).to eql([[:sql, 'SELECT 1 FROM users']])
    end

    it 'allows instrumenting via block' do
      captured = []
      payload = { query: 'SELECT 1 FROM users' }

      notifications.subscribe(:sql) do |event|
        captured << [event.id, event[:query]]
      end

      notifications.instrument(:sql, payload) do
        payload
      end

      expect(captured).to eql([[:sql, 'SELECT 1 FROM users']])
    end
  end
end
