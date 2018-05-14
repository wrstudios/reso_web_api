RSpec.describe ResoWebApi::Authentication::Middleware do
  let(:access) { instance_double('ResoWebApi::Authentication::Access') }
  let(:auth)   { instance_double('ResoWebApi::Authentication::AuthStrategy') }
  let(:auth_success) do
    # Stub response to echo authorization header
    -> (env) { [200, {}, env[:request_headers]['Authorization']] }
  end
  let(:auth_failure) do
    # Stub response to return 401 Access Denied
    -> (env) { [401, {}, 'Access Denied'] }
  end
  let(:conn) do
    # @see https://github.com/lostisland/faraday/blob/master/test/authentication_middleware_test.rb
    Faraday::Connection.new('http://example.net') do |conn|
      conn.use ResoWebApi::Authentication::Middleware, auth
      conn.adapter :test do |stub|
        stub.get('/auth-echo') { |env| @responses.shift.call(env) }
      end
    end
  end

  before do
    # Mock access
    allow(access).to receive(:token).and_return('0xdeadbeef')
    allow(access).to receive(:token_type).and_return('Bearer')
    # Mock auth
    allow(auth).to receive(:access).and_return(access)
    allow(auth).to receive(:ensure_valid_access!).and_return(access)
  end

  it 'sets authorization header' do
    @responses = [auth_success]
    expect(conn.get('/auth-echo').body).to eq('Bearer 0xdeadbeef')
  end

  context 'when service rejects authentication' do
    it 'retries the request once' do
      @responses = [auth_failure, auth_success]
      # Expect middleware to retry authentication and eventually return a value
      expect(auth).to receive(:ensure_valid_access!).twice
      expect(auth).to receive(:reset)
      expect(conn.get('/auth-echo').body).to eq('Bearer 0xdeadbeef')
    end

    it 'gives up after that' do
      @responses = [auth_failure, auth_failure]
      expect(auth).to receive(:reset)
      expect { conn.get('/auth-echo') }.to raise_error(ResoWebApi::Errors::AccessDenied)
    end
  end
end
