require 'spec_helper'

RSpec.describe Dry::Monitor::Rack::Middleware do
  subject(:middleware) { Dry::Monitor::Rack::Middleware.new(notifications).new(rack_app) }

  let(:notifications) do
    Dry::Monitor::Notifications.new(:test)
  end

  let(:rack_app) do
    double(:rack_app)
  end

  let(:log_file_path) do
    SPEC_ROOT.join('test_logs/middleware.log')
  end

  let(:rack_logger) do
    Dry::Monitor::Rack::Logger.new(Dry::Monitor::Logger.new(log_file_path))
  end

  describe '#call' do
    let(:env) do
      { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/hello-world', 'REMOTE_ADDR' => '0.0.0.0', 'QUERY_PARAMS' => query_params }
    end

    let(:query_params) do
      '_csrf=123456&password=secret&user[password]=secret&other[][password]=secret&other[][password]=secret&foo=bar&one=1'
    end

    before do
      File.open(log_file_path, 'w').close
      rack_logger.subscribe(middleware)
    end

    it 'triggers start/stop events for with a rack request' do
      expect(rack_app).to receive(:call).with(env).and_return([200, :total_success])

      status, response = middleware.call(env)

      expect(status).to be(200)
      expect(response).to be(:total_success)

      log_file_content = File.read(log_file_path)

      expect(log_file_content).to include('Started GET "/hello-world"')
      expect(log_file_content).to include('Finished GET "/hello-world"')
      expect(log_file_content).to include('Query parameters {"_csrf"=>"[FILTERED]", "password"=>"[FILTERED]", "user"=>{"password"=>"[FILTERED]"}, "other"=>[{"password"=>"[FILTERED]"}, {"password"=>"[FILTERED]"}], "foo"=>"bar", "one"=>"1"}')
    end
  end

  describe '#on' do
    it 'subscribe a listener to a specific request event' do
      captured = []

      middleware.on(:error) do |id, payload|
        captured << payload
      end

      middleware.instrument(:error, exception: 'oops')

      expect(captured).to eql([exception: 'oops'])
    end
  end
end
