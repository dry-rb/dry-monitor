require 'spec_helper'

RSpec.describe Dry::Monitor::SQL::Logger do
  subject(:logger) { sql_logger.new(Dry::Monitor::Logger.new(log_file_path)) }

  let(:notifications) do
    Dry::Monitor::Notifications.new(:test)
  end

  let(:log_file_path) do
    SPEC_ROOT.join('../tmp/sql.log')
  end

  let(:log_file_content) { File.read(log_file_path) }

  shared_context '#subscribe' do
    let(:query) do
      'SELECT id, name FROM users'
    end

    before do
      File.open(log_file_path, 'w').close

      logger.subscribe(notifications)

      notifications.instrument(:sql, name: 'users', query: query) do
        sleep 0.0025
      end
    end

    it 'writes sql query info' do
      expect(log_file_content).to include('Loaded "users" in')
    end
  end

  context 'without colors' do
    let(:sql_logger) do
      Class.new(Dry::Monitor::SQL::Logger) do
        configure do |config|
          config.colorize = false
        end
      end
    end

    include_context '#subscribe' do
      it 'writes sql query in logs' do
        expect(log_file_content).to include(query)
      end
    end
  end

  context 'without colors' do
    let(:sql_logger) do
      Dry::Monitor::SQL::Logger
    end

    include_context '#subscribe'
  end
end
