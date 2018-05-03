RSpec.describe ResoWebApi::BaseClient do
  let(:endpoint) { 'http://www.google.com/' }

  context 'with default options' do
    subject { ResoWebApi::BaseClient.new(endpoint: endpoint) }

    describe '#adapter' do
      it { expect(subject.adapter).to eq(Faraday.default_adapter) }
    end

    describe '#connection' do
      it { expect(subject.connection).to be_a(Faraday::Connection) }
      it { expect(subject.connection.url_prefix.to_s).to eq(endpoint) }
    end

    describe '#headers' do
      it { expect(subject.headers).to be_a(Hash) }
      it { expect(subject.headers).to include(user_agent: ResoWebApi::BaseClient::USER_AGENT) }
    end
  end

  context 'when overriding adapter and user agent' do
    let(:adapter) { :typhoeus }
    let(:user_agent) { 'FooBar/1.2.3'}
    subject { ResoWebApi::BaseClient.new(endpoint: endpoint, adapter: adapter, user_agent: user_agent) }

    describe '#adapter' do
      it { expect(subject.adapter).to eq(adapter) }
    end

    describe '#headers' do
      it { expect(subject.headers).to include(user_agent: user_agent) }
    end
  end
end