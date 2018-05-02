RSpec.describe ResoWebApi::Authentication::TokenAuth do
  subject do
    ResoWebApi::Authentication::TokenAuth.new(config)
  end
  let(:config) {{
    endpoint:   ENV['AUTH_ENDPOINT'],
    api_key:    ENV['API_KEY'],
    api_secret: ENV['API_SECRET'],
    scope:      ENV['SCOPE']
  }}

  describe '#authenticate' do
    it 'authenticates the API credentials' do
      access = subject.authenticate
      expect(access).to be_a(ResoWebApi::Authentication::Session)
      expect(access).to be_valid
    end

    it 'raises an exception when the credentials are invalid' do
      config[:api_secret] = 'T0pS3cr3t'
      expect { subject.authenticate }.to raise_error(ResoWebApi::ClientError)
    end
  end
end
