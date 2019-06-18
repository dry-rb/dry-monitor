# frozen_string_literal: true

RSpec.describe Dry::Monitor::SQL::Logger do
  subject(:logger) { sql_logger.new(Dry::Monitor::Logger.new(log_file_path)) }

  let(:notifications) do
    Dry::Monitor::Notifications.new(:test)
  end

  let(:log_file_path) do
    SPEC_ROOT.join('test_logs/sql.log')
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
      Dry::Monitor::SQL::Logger.load_extensions(:rouge_colorizer)
      Dry::Monitor::SQL::Logger
    end

    include_context '#subscribe' do
      let(:colored_query) do
        "\e[38;5;203mSELECT\e[39m\e[38;5;230m"
      end

      it 'writes sql query in logs' do
        expect(log_file_content).to include(colored_query)
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
