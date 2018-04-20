RSpec.describe ResoWebApi do
  it 'has a version number' do
    expect(subject::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  describe '#client' do
    it 'gives me a client connection' do
      expect(subject.client).to be_a(ResoWebApi::Client)
    end
  end

  describe '#reset' do
    it 'resets my connection' do
      client = subject.client
      subject.reset
      expect(subject.client).not_to eq(client)
    end
  end

  describe '#logger' do
    it 'lets me access and override the logger' do
      expect(subject.logger.level).to eq(Logger::INFO) 

      subject.logger = Logger.new('/dev/null')
      subject.logger.level = Logger::WARN

      expect(subject.logger.level).to eq(Logger::WARN)
    end
  end
end
