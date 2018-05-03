RSpec.describe ResoWebApi::Authentication::Access do
  subject { ResoWebApi::Authentication::Access.new(token_response) }
  let(:token_response) {{
    'access_token' => '0xdeadbeef',
    'token_type'   => 'Bearer',
    'expires_in'   => 3600
  }}

  describe '#token' do
    it 'returns the access token' do
      expect(subject.token).to eq('0xdeadbeef')
    end
  end

  describe '#token_type' do
    it 'returns the token type' do
      expect(subject.token_type).to eq('Bearer')
    end
  end

  describe '#expires' do
    it 'returns the expiration time' do
      expect(subject.expires).to be_a(Time)
    end
  end

  describe '#expired?' do
    it 'returns false if token has not expired' do
      expect(subject.expired?).to eq(false)
    end

    it 'returns true if token has expired' do
      subject.expires = Time.now
      expect(subject.expired?).to eq(true)
    end
  end

  describe '#valid?' do
    it 'returns true if token is present and not expired' do
      expect(subject.valid?).to eq(true)
    end

    it 'returns false if token is not present' do
      subject.token = nil
      expect(subject.valid?).to eq(false)
    end

    it 'returns false if token is expired' do
      subject.expires = Time.now
      expect(subject.valid?).to be(false)
    end
  end
end
