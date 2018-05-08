RSpec.describe ResoWebApi::Authentication::BaseAuth do
  subject do
    ResoWebApi::Authentication::BaseAuth.new(endpoint: '', api_key: '', api_secret: '')
  end

  describe '#authenticate' do
    it 'should raise an error' do
      expect { subject.authenticate }.to raise_error(NotImplementedError)
    end
  end

  describe '#ensure_valid_access!' do
    let(:access) { instance_double('ResoWebApi::Authentication::Access') }

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
end
