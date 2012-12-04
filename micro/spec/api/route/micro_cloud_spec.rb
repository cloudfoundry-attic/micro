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

  describe 'http_proxy' do

    it 'returns 200 when the HTTP proxy is the empty string' do
      apply_spec = double('apply_spec').as_null_object
      bosh_wrapper = double('bosh_wrapper').as_null_object

      VCAP::Micro::ApplySpec.should_receive(:new).and_return(apply_spec)
      VCAP::Micro::BoshWrapper.should_receive(:new).and_return(bosh_wrapper)

      post '/', { 'http_proxy' => '' }.to_json,
      'CONTENT_TYPE' => 'application/vnd.vmware.mcf-micro-cloud+json'

      last_response.should be_ok
    end

    it 'returns 200 when the HTTP proxy is a valid URL' do
      apply_spec = double('apply_spec').as_null_object
      bosh_wrapper = double('bosh_wrapper').as_null_object

      VCAP::Micro::ApplySpec.should_receive(:new).and_return(apply_spec)
      VCAP::Micro::BoshWrapper.should_receive(:new).and_return(bosh_wrapper)

      post '/', { 'http_proxy' => 'http://company.com?:3128/' }.to_json,
      'CONTENT_TYPE' => 'application/vnd.vmware.mcf-micro-cloud+json'

      last_response.should be_ok
    end

    it 'returns 400 when the HTTP proxy is invalid' do
      post '/', { 'http_proxy' => 'not a url' }.to_json,
      'CONTENT_TYPE' => 'application/vnd.vmware.mcf-micro-cloud+json'

      last_response.status.should == 400
      last_response.body.should == 'HTTP proxy is not a valid URL'
    end

  end
end
