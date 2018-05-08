RSpec.describe ResoWebApi::Authentication::Middleware do
  # @see https://github.com/lostisland/faraday/blob/master/test/authentication_middleware_test.rb
  def conn(response)
    Faraday::Connection.new('http://example.net') do |conn|
      conn.use ResoWebApi::Authentication::Middleware, auth
      conn.adapter :test do |stub|
        stub.get('/auth-echo', &response)
      end
    end
  end

  let(:access) { instance_double('ResoWebApi::Authentication::Access') }
  let(:auth)   { instance_double('ResoWebApi::Authentication::BaseAuth') }

  before do
    # Mock access
    allow(access).to receive(:token).and_return('0xdeadbeef')
    allow(access).to receive(:token_type).and_return('Bearer')
    # Mock auth
    allow(auth).to receive(:access).and_return(access)
    allow(auth).to receive(:ensure_valid_access!).and_return(access)
  end

  it 'sets authorization header' do
    # Stub response to echo authorization header
    response = -> (env) { [200, {}, env[:request_headers]['Authorization']] }
    expect(conn(response).get('/auth-echo').body).to eq('Bearer 0xdeadbeef')
  end

  it 'raises an exception if authorization was rejected' do
    # Stub response to return 401 Access Denied
    response = -> (env) { [401, {}, 'Access Denied'] }
    expect { conn(response).get('/auth-echo') }.to raise_error(ResoWebApi::Errors::AccessDenied)
  end

  it 'raises an exception if credentials were rejected' do
    expect(auth).to receive(:ensure_valid_access!).and_raise(ResoWebApi::Errors::AccessDenied)
    expect { conn(nil).get('/auth-echo') }.to raise_error(ResoWebApi::Errors::AccessDenied)
  end
end
