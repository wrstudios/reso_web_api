RSpec.describe ResoWebApi::ServiceProxy do
  subject { ResoWebApi::ServiceProxy.new(client, service) }
  let(:client)   { ResoWebApi::Client.new(endpoint: endpoint, auth: auth) }
  let(:service)  { instance_double('OData4::Service') }
  let(:auth)     { instance_double('ResoWebApi::Authentication::BaseAuth') }
  let(:access)   { instance_double('ResoWebApi::Authentication::Access') }
  let(:endpoint) { 'http://services.odata.org/V4/OData/OData.svc' }

  before do
    # Mock auth strategy
    allow(auth).to receive(:authenticate).and_return(access)
    # Mock access
    allow(access).to receive(:token_type).and_return('Bearer')
    allow(access).to receive(:token).and_return('0xdeadbeef')
    allow(access).to receive(:valid?).and_return(true)
    # Mock service to raise an exception the first time and return a value the second
    allow(client).to receive(:service).and_return(service)
    allow(service).to receive(:entity_sets) do
      @responses.shift || raise(OData4::Errors::AccessDenied, nil)
    end
  end

  it 'responds to the same methods as OData4::Service' do
    service.public_methods(false).each do |method|
      expect(subject.respond_to? method).to eq(true)
    end
  end

  it 'sets proper authorization header when making HTTP requests' do
    @responses = [{}]
    subject.entity_sets
    expect(client.connection.headers).to include('Authorization' => 'Bearer 0xdeadbeef')
  end

  context 'when service rejects authentication' do
    it 'retries the request once' do
      @responses = [nil, {}]
      # Expect method to retry authentication and eventually return a value
      expect(auth).to receive(:authenticate).and_return(access).twice
      expect(subject.entity_sets).to eq({})
    end

    it 'gives up after that' do
      @responses = [nil, nil]
      expect { subject.entity_sets }.to raise_error(OData4::Errors::AccessDenied)
    end
  end
end
