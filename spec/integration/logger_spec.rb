RSpec.describe Dry::Monitor::Logger do
  subject(:logger) do
    Dry::Monitor::Logger.new($stdout)
  end

  describe '#info' do
    it 'outputs with configured formatter' do
      expect { logger.info('test') }.to output("test\n").to_stdout
    end
  end
end
