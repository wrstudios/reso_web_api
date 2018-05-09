RSpec.describe ResoWebApi::Client do
  subject { ResoWebApi::Client.new(endpoint: endpoint, auth: auth) }
  let(:auth) { instance_double('ResoWebApi::Authentication::BaseAuth') }
  let(:access) { instance_double('ResoWebApi::Authentication::Access') }
  let(:endpoint) { 'http://services.odata.org/V4/OData/OData.svc' }

  describe '.new' do
    it 'requires auth option' do
      expect { ResoWebApi::Client.new(endpoint: endpoint) }.to raise_error(ArgumentError, /auth/)
    end
  end

  describe '#connection' do
    it 'uses authentication middleware' do
      expect(subject.connection.builder.handlers).to include(
        ResoWebApi::Authentication::Middleware
      )
    end
  end

  describe '#service' do
    let(:stub) { Faraday::Adapter::Test::Stubs.new }

    before do
      allow(auth).to receive(:ensure_valid_access!)
      allow(auth).to receive(:access).and_return(access)
      # Use Faraday test adapter to avoid making real network connections
      subject.connection { |conn| conn.adapter :test, stub }
      # Stub out connection to OData service
      stub.get('/V4/OData/OData.svc/$metadata') { |env| [200, {}, ''] }
    end

    it 'returns a OData service object with an authorized connection' do
      expect(access).to receive(:token).and_return('0xdeadbeef')
      expect(access).to receive(:token_type).and_return('Bearer')
      expect(subject.service).to be_a(OData4::Service)
    end
  end
end
