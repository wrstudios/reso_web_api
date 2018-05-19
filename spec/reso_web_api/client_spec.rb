RSpec.describe ResoWebApi::Client do
  subject { ResoWebApi::Client.new(options) }
  let(:options) {{ endpoint: endpoint, auth: auth }}
  let(:auth) { instance_double('ResoWebApi::Authentication::AuthStrategy') }
  let(:access) { instance_double('ResoWebApi::Authentication::Access') }
  let(:endpoint) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:metadata) { 'spec/fixtures/files/metadata.xml' }

  describe '.new' do
    it 'requires auth option' do
      expect { ResoWebApi::Client.new(endpoint: endpoint) }.to raise_error(ArgumentError, /auth/)
    end

    it 'instantiates auth strategy if given a hash' do
      client = ResoWebApi::Client.new(
        endpoint: endpoint,
        auth: {
          strategy: ResoWebApi::Authentication::AuthStrategy,
          endpoint: ''
        }
      )
      expect(client.auth).to be_a(ResoWebApi::Authentication::AuthStrategy)
    end

    it 'defaults to TokenAuth if no strategy was selected' do
      client = ResoWebApi::Client.new(endpoint: endpoint, auth: {
        endpoint: '', client_id: '', client_secret: '', scope: ''
      })
      expect(client.auth).to be_a(ResoWebApi::Authentication::TokenAuth)
    end

    it 'ensures that a valid auth strategy is selected' do
      expect {
        ResoWebApi::Client.new(endpoint: endpoint, auth: {
          strategy: Object
        })
      }.to raise_error(ArgumentError, /not a valid auth strategy/)
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

    def stub_connection
      # Use Faraday test adapter to avoid making real network connections
      subject.connection { |conn| conn.adapter :test, stub }
      # Stub out connection to OData service
      stub.get('/V4/OData/OData.svc/$metadata') do |env|
        [ 200, { content_type: 'application/xml' }, File.read(metadata) ]
      end
    end

    before do
      # Stub auth
      allow(auth).to receive(:ensure_valid_access!)
      allow(auth).to receive(:access).and_return(access)
      # Stub access
      allow(access).to receive(:token).and_return('0xdeadbeef')
      allow(access).to receive(:token_type).and_return('Bearer')
    end

    it 'returns a OData service object with an authorized connection' do
      stub_connection
      expect(access).to receive(:token)
      expect(access).to receive(:token_type)
      expect(subject.service).to be_a(FrOData::Service)
    end

    it 'is aliased to #resources' do
      stub_connection
      expect(subject.resources).to be_a(FrOData::Service)
    end

    it 'uses OData options passed to constructor' do
      options[:odata] = { metadata_file: metadata }
      expect(subject.service.options).to include(metadata_file: metadata)
    end
  end

  ResoWebApi::Resources::STANDARD_RESOURCES.each do |method, resource|
    describe "##{method}" do
      # Stub out service to avoid making network requests
      let(:service) { instance_double('FrOData::Service') }
      before { subject.instance_variable_set(:@service, service) }

      it "gives me access to the #{resource} resource" do
        expect(service).to receive(:[]).with(resource)
        subject.send(method)
      end
    end
  end
end
