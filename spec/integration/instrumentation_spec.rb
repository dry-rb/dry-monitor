require 'spec_helper'

RSpec.describe 'Subscribing to instrumentation events' do
  subject(:notifications) { Dry::Monitor::Notifications.new(:app) }

  describe '#instrument' do
    it 'allows subscribing listeners to specific events' do
      payload = { query: 'SELECT 1 FROM users' }
      captured = []
      listener = -> id, payload { captured << [id, payload] }

      notifications.event(:sql, { name: 'rom[sql]' }).subscribe(:sql, listener)

      notifications.instrument(:sql, payload)

      expect(captured).to eql([[:sql, { name: 'rom[sql]', query: 'SELECT 1 FROM users'}]])
    end

    it 'allows subscribing via block' do
      captured = []
      payload = { query: 'SELECT 1 FROM users' }

      notifications.event(:sql, { name: 'rom[sql]' }).subscribe(:sql) do |id, payload|
        captured << [id, payload]
      end

      notifications.instrument(:sql, payload)

      expect(captured).to eql([[:sql, { name: 'rom[sql]', query: 'SELECT 1 FROM users'}]])
    end

    it 'allows instrumenting via block' do
      captured = []
      payload = { query: 'SELECT 1 FROM users' }

      notifications.event(:sql, { name: 'rom[sql]' }).subscribe(:sql) do |time, id, payload|
        captured << [id, payload]
      end

      notifications.instrument(:sql, payload) do
        payload
      end

      expect(captured).to eql([[:sql, { name: 'rom[sql]', query: 'SELECT 1 FROM users'}]])
    end
  end
end
