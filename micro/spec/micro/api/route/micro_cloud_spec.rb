require 'spec_helper'

describe 'micro cloud resource' do
  include Rack::Test::Methods

  let(:app) { VCAP::Micro::Api::Server }

  describe 'http_proxy' do
    let(:apply_spec) { double('apply_spec').as_null_object }
    let(:bosh_wrapper) { double('bosh_wrapper').as_null_object }

    context "when HTTP proxy is a valid URL" do
      ['', 'http://company.com?:3128/', 'company.com:3128/', 'foo'].each do |url|
        context "when URL is '#{url}'" do
          it 'returns 200' do
            VCAP::Micro::ApplySpec.should_receive(:new).and_return(apply_spec)
            VCAP::Micro::BoshWrapper.should_receive(:new).and_return(bosh_wrapper)

            post '/', {'http_proxy' => url}.to_json,
                 'CONTENT_TYPE' => 'application/vnd.vmware.mcf-micro-cloud+json'

            last_response.should be_ok
          end
        end
      end
    end

    it 'returns 400 when the HTTP proxy is invalid' do
      post '/', {'http_proxy' => 'not a url'}.to_json,
           'CONTENT_TYPE' => 'application/vnd.vmware.mcf-micro-cloud+json'

      last_response.status.should == 400
      last_response.body.should == 'HTTP proxy is not a valid URL'
    end

  end
end
