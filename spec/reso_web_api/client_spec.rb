RSpec.describe ResoWebApi::Client do
  subject { ResoWebApi::Client.new(endpoint: endpoint, auth: auth) }
  let(:auth) { instance_double('ResoWebApi::Authentication::BaseAuth') }
  let(:access) { instance_double('ResoWebApi::Authentication::Access') }
  let(:endpoint) { 'http://services.odata.org/V4/OData/OData.svc' }

  describe '#authenticate' do
    it 'calls #authenticate on the auth strategy with a given code' do
      expect(auth).to receive(:authenticate).with('some-code')
      subject.authenticate('some-code')
    end

    it "sets the client's access to the result of the call" do
      allow(auth).to receive(:authenticate).and_return(access)

      subject.authenticate
      expect(subject.access).to eq(access)
    end
  end

  describe '#refresh' do
    it 'calls #refresh on the auth strategy' do
      subject.access = access

      expect(auth).to receive(:refresh).with(subject.access)
      subject.refresh
    end

    it "sets the client's access to the result of the call" do
      allow(auth).to receive(:refresh).and_return(access)

      subject.refresh
      expect(subject.access).to eq(access)
    end
  end

  describe '#request' do
    before do
      # Mock auth strategy
      allow(auth).to receive(:authenticate).and_return(access)
      # Mock access
      allow(access).to receive(:token_type).and_return('Bearer')
      allow(access).to receive(:token).and_return('0xdeadbeef')
      allow(access).to receive(:valid?).and_return(true)
    end

    it 'yields a OData4::Service object' do
      subject.request do |service|
        expect(service).to be_a(OData4::Service)
      end
    end

    it 'service object has a connection with proper authorization headers' do
      subject.request do |service|
        expect(service.connection.headers).to include('Authorization' => 'Bearer 0xdeadbeef')
      end
    end

    context 'when service rejects authentication' do
      before do
        # Mock service to raise an exception the first time and return a value the second
        service = instance_double('OData4::Service')
        allow(subject).to receive(:service).and_return(service)
        allow(service).to receive(:entity_sets) do
          @responses.shift || raise(OData4::Errors::AccessDenied, nil)
        end
      end

      it 'retries the request once' do
        @responses = [nil, {}]
        # Expect method to retry authentication and eventually return a value
        expect(auth).to receive(:authenticate).and_return(access).twice
        expect(subject.request { |service| service.entity_sets }).to eq({})
      end

      it 'gives up after that' do
        @responses = [nil, nil]
        expect { subject.request { |service| service.entity_sets } }.to raise_error(OData4::Errors::AccessDenied)
      end
    end
  end
end
