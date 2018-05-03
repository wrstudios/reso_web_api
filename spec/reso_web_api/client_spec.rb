RSpec.describe ResoWebApi::Client do
  subject { ResoWebApi::Client.new(endpoint: endpoint, auth: auth) }
  let(:auth) { instance_double('ResoWebApi::Authentication::BaseAuth') }
  let(:access) { double('ResoWebApi::Authentication::Session') }
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

  describe '#connection' do
    before do
      expect(auth).to receive(:authenticate).and_return(access)
      expect(access).to receive(:token_type).and_return('Bearer')
      expect(access).to receive(:token).and_return('0xdeadbeef')
    end

    it 'authenticates the connection by setting a proper header' do
      expect(subject.connection.headers).to include('Authorization' => 'Bearer 0xdeadbeef')
    end
  end

  describe '#service' do
    before do
      allow(auth).to receive(:authenticate).and_return(access)
      allow(access).to receive(:token_type).and_return('Bearer')
      allow(access).to receive(:token).and_return('0xdeadbeef')
      allow(access).to receive(:valid?).and_return(true)
    end

    it 'returns a OData4::Service object' do
      expect(subject.service).to be_a(OData4::Service)
    end

    it 'uses shares the same connection object' do
      expect(subject.service.connection).to eq(subject.connection)
    end
  end
end
