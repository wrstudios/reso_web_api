RSpec.describe ResoWebApi do
  it 'has a version number' do
    expect(subject::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  # describe '#client' do
  #   it 'gives me a client connection' do
  #     expect(subject.client).to be_a(ResoWebApi::Client)
  #   end
  # end
  #
  # describe '#reset' do
  #   it 'resets my connection' do
  #     client = subject.client
  #     subject.reset
  #     expect(subject.client).not_to eq(client)
  #   end
  #
  #   it 'resets configuration to defaults' do
  #     subject.api_key = 'test key'
  #     subject.reset
  #     expect(subject.api_key).to be_nil
  #   end
  # end

  describe '#logger' do
    it 'lets me access and override the logger' do
      # Overridden in spec_helper.rb
      expect(subject.logger.level).to eq(Logger::DEBUG)

      subject.logger = Logger.new('/dev/null')
      subject.logger.level = Logger::WARN

      expect(subject.logger.level).to eq(Logger::WARN)
    end
  end
end
