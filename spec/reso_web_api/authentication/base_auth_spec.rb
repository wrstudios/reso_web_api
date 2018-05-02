RSpec.describe ResoWebApi::Authentication::BaseAuth do
  subject do
    ResoWebApi::Authentication::BaseAuth.new(
      endpoint: '', api_key: '', api_secret: ''
    )
  end

  describe '#authenticate' do
    it 'should raise an error' do
      expect { subject.authenticate }.to raise_error(NotImplementedError)
    end
  end

  describe '#refresh' do
    it 'should raise an error' do
      expect { subject.refresh(nil) }.to raise_error(NotImplementedError)
    end
  end
end
