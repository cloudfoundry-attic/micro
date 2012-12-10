require 'fakeweb'

require 'micro/dns_api_client'

describe VCAP::Micro::DnsApiClient do

  describe '#client' do

    subject {
      VCAP::Micro::DnsApiClient.new(
        :root_url => 'test.com',
        :http_proxy => 'http://proxy.com:1234'
      ).client
    }

    it { should be_a RestClient::Resource }

    its(:url) { should == 'test.com' }

    specify { RestClient.proxy.should == 'http://proxy.com:1234' }

  end

  describe '#redeem_nonce' do

    it 'redeems the nonce' do
      FakeWeb.register_uri(
        :post, 'http://test.com/token',
        :body => '{ "ok" : 1 }'
      )

      client = VCAP::Micro::DnsApiClient.new(:root_url => 'test.com')
      client.redeem_nonce('test').should == { "ok" => 1 }
    end

  end

  describe '#update_dns' do

    it 'updates the DNS' do
      FakeWeb.register_uri(
        :put, 'http://test.com/clouds/cloud/name/dns',
        :body => '{ "ok" : 1 }'
      )

      client = VCAP::Micro::DnsApiClient.new(:root_url => 'test.com')
      client.update_dns('192.168.0.2',
        'cloud' => 'cloud',
        'name' => 'name',
        'auth-token' => 'auth-token').should == '{ "ok" : 1 }'
    end

  end

end
