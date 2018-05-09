RSpec.describe ResoWebApi::Authentication::BaseAuth do
  subject do
    ResoWebApi::Authentication::BaseAuth.new(endpoint: '')
  end
  let(:access) { instance_double('ResoWebApi::Authentication::Access') }

  describe '#authenticate' do
    it 'should raise an error' do
      expect { subject.authenticate }.to raise_error(NotImplementedError)
    end
  end

  describe '#ensure_valid_access!' do
    it 'authenticates and returns access' do
      expect(subject).to receive(:authenticate).and_return(access)
      expect(subject.ensure_valid_access!).to eq(access)
    end

    it 'does not re-authenticate if access is valid' do
      allow(subject).to receive(:access).and_return(access)
      expect(access).to receive(:valid?).and_return(true)
      expect(subject).not_to receive(:authenticate)
      expect(subject.ensure_valid_access!).to eq(access)
    end

    it 'raises an exception if authentication fails' do
      expect(subject).to receive(:authenticate).and_raise(ResoWebApi::Errors::AccessDenied)
      expect { subject.ensure_valid_access! }.to raise_error(ResoWebApi::Errors::AccessDenied)
    end
  end

  describe 'reset' do
    it 'resets authentication' do
      subject.instance_variable_set(:@access, access)
      expect { subject.reset }.to change { subject.access }.to(nil)
    end
  end
end
