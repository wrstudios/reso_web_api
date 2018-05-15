RSpec.describe ResoWebApi::Authentication::SimpleTokenAuth do
  subject { ResoWebApi::Authentication::SimpleTokenAuth.new(config) }
  let(:config) {{
    access_token: 'eyJ0eXAiOiJKV1Qi',
    token_type:   'Bearer'
  }}

  describe '#authenticate' do
    it { expect(subject.authenticate).to be_a(ResoWebApi::Authentication::Access) }
    it { expect(subject.authenticate).to be_valid }
    it { expect(subject.authenticate.token).to eq(config[:access_token]) }
    it { expect(subject.authenticate.token_type).to eq(config[:token_type])}
  end
end
