# frozen_string_literal: true

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

  let(:env) do
    { 'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/hello-world',
      'REMOTE_ADDR' => '0.0.0.0',
      'QUERY_STRING' => query_params }
  end

  let(:query_params) do
    %w[
      _csrf=123456
      password=secret
      user[password]=secret
      others[][password]=secret1
      others[][password]=secret2
      foo=bar
      one=1
      ids[]=1
      ids[]=2
    ].join('&')
  end

  describe '#call' do
    before do
      File.open(log_file_path, 'w').close
      rack_logger.attach(middleware)
    end

    it 'triggers start/stop events for with a rack request' do
      expect(rack_app).to receive(:call).with(env).and_return([200, :total_success])

      status, response = middleware.call(env)

      expect(status).to be(200)
      expect(response).to be(:total_success)

      log_file_content = File.read(log_file_path)

      expect(log_file_content).to include('Started GET "/hello-world"')
      expect(log_file_content).to include('Finished GET "/hello-world"')
      expect(log_file_content).to include('Query parameters {"_csrf"=>"[FILTERED]", "password"=>"[FILTERED]", "user"=>{"password"=>"[FILTERED]"}, "others"=>[{"password"=>"[FILTERED]"}, {"password"=>"[FILTERED]"}], "foo"=>"bar", "one"=>"1", "ids"=>["1", "2"]}')
    end
  end

  describe '#on' do
    it 'subscribe a listener to a specific request event' do
      captured = []

      middleware.on(:error) do |event|
        captured << event[:exception]
        captured << event[:env]
      end

      exception = 'oops'
      env = { 'REQUEST_METHOD' => 'GET' }

      middleware.instrument(:error, exception: exception, env: env)

      expect(captured).to eql([exception, env])
    end
  end

  describe 'rack logger' do
    before do
      File.open(log_file_path, 'w').close
      rack_logger.attach(middleware)
    end

    it 'logs exceptions' do
      exception = double(:exception, message: 'oops', backtrace: ['/some/path.rb'])

      middleware.instrument(:error, exception: exception, env: env)

      log_file_content = File.read(log_file_path)

      expect(log_file_content).to include('oops')
      expect(log_file_content).to include('/some/path.rb')
    end
  end
end
