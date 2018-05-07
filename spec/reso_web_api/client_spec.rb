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
end
