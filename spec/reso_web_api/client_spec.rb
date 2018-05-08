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

  describe '#connection' do
    it 'injects authentication middleware' do
      expect(subject.connection.builder.handlers).to include(
        ResoWebApi::Authentication::Middleware
      )
    end
  end

  describe '#service' do
    it 'returns a service proxy' do
      expect(subject.service).to be_a(ResoWebApi::ServiceProxy)
    end
  end
end
