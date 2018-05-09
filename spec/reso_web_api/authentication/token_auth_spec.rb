RSpec.describe ResoWebApi::Authentication::TokenAuth do
  subject { ResoWebApi::Authentication::TokenAuth.new(config) }
  let(:config) {{
    endpoint:      'https://auth.my-mls.org/connect/token',
    client_id:     'deadbeef',
    client_secret: 'T0pS3cr3t',
    scope:         'odata'
  }}
  let(:valid_auth) {
    {
      "access_token" => "eyJ0eXAiOiJKV1Qi",
      "expires_in"   => 3600,
      "token_type"   => "Bearer"
    }.to_json
  }
  let(:invalid_auth) { { 'error' => 'invalid_client' }.to_json }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  # Use Faraday test adapter and inject request stubs
  before { subject.connection { |conn| conn.adapter :test, stubs } }

  describe '#authenticate' do
    it 'returns valid access if authentication succeeds' do
      stubs.post('/connect/token') { |env| [200, {}, valid_auth] }
      access = subject.authenticate
      expect(access).to be_a(ResoWebApi::Authentication::Access)
      expect(access).to be_valid
    end

    it 'raises an exception when authentication fails' do
      stubs.post('/connect/token') { |env| [400, {}, invalid_auth] }
      expect { subject.authenticate }.to raise_error(ResoWebApi::Errors::AccessDenied)
    end
  end
end
