RSpec.describe ResoWebApi::Client do
  describe 'default settings' do
    it 'returns the default configuration' do
      expect(ResoWebApi.api_key    ).to be_nil
      expect(ResoWebApi.api_secret ).to be_nil
      expect(ResoWebApi.auth_url   ).to be_nil
      expect(ResoWebApi.service_url).to be_nil
      expect(ResoWebApi.user_agent ).to match(/Reso Web API Ruby gem .*/)
    end
  end

  describe 'instance configuration' do
    let(:config) { {
      :api_key     => 'test key',
      :api_secret  => 'T0pS3cr3t',
      :auth_url    => 'https://auth.reso.org',
      :service_url => 'https://odata.reso.org',
      :user_agent  => 'RSpec'
    } }

    it 'should return a property configured client' do
      client = ResoWebApi::Client.new(config)

      config.each do |key, value|
        expect(client.send(key)).to eq(value)
      end
    end
  end

  describe 'block configuration' do
    it 'should correctly set up the client' do
      ResoWebApi.configure do |config|
        config.api_key     = 'test key'
        config.api_secret  = 'T0pS3cr3t'
        config.auth_url    = 'https://auth.reso.org'
        config.service_url = 'https://odata.reso.org'
        config.user_agent  = 'RSpec'
      end

      expect(ResoWebApi.api_key    ).to eq('test key')
      expect(ResoWebApi.api_secret ).to eq('T0pS3cr3t')
      expect(ResoWebApi.auth_url   ).to eq('https://auth.reso.org')
      expect(ResoWebApi.service_url).to eq('https://odata.reso.org')
      expect(ResoWebApi.user_agent ).to eq('RSpec')
    end
  end
end
