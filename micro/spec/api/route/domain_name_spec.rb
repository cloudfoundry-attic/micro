require 'spec_helper'

# Hack until bosh_agent becomes a gem.
module VCAP

  module Micro

    class BoshWrapper
    end

  end

end

require 'micro/api'

describe 'micro cloud resource' do
  include Rack::Test::Methods

  class VCAP::Micro::Api::Server
    use VCAP::Micro::Api::Engine::Rack::MediaTypeSerial
  end

  def app
    VCAP::Micro::Api::Server
  end

  describe 'name' do

    it 'returns 200 when the domain name is valid' do
      apply_spec = double('apply_spec').as_null_object
      bosh_wrapper = double('bosh_wrapper').as_null_object
      config_file = double('config_file').as_null_object
      dnsmasq = double('dnsmasq').as_null_object
      internet_connection = double('internet_connection').as_null_object

      VCAP::Micro::ApplySpec.should_receive(:new).and_return(apply_spec)
      VCAP::Micro::BoshWrapper.should_receive(:new).and_return(bosh_wrapper)
      VCAP::Micro::ConfigFile.should_receive(:new).and_return(config_file)
      VCAP::Micro::Dnsmasq.should_receive(:new).and_return(dnsmasq)
      VCAP::Micro::InternetConnection.should_receive(:new).and_return(
        internet_connection)

      post '/domain_name', { 'name' => 'test.micro' }.to_json,
      'CONTENT_TYPE' => 'application/vnd.vmware.mcf-domain-name+json'

      last_response.should be_ok
    end

    it 'returns 400 when the domain is invalid' do
      apply_spec = double('apply_spec').as_null_object
      config_file = double('config_file').as_null_object

      VCAP::Micro::ApplySpec.should_receive(:new).and_return(apply_spec)
      VCAP::Micro::ConfigFile.should_receive(:new).and_return(config_file)

      post '/domain_name', { 'name' => 'test' }.to_json,
      'CONTENT_TYPE' => 'application/vnd.vmware.mcf-domain-name+json'

      last_response.status.should == 400
      last_response.body.should == 'Domain is invalid'
    end

  end
end
