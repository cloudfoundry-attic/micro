require 'spec_helper'

describe VCAP::Micro::Client do
  subject { VCAP::Micro::Client.new }

  let(:cfoundry_client) do
    client = mock(:cfoundry_client)
    client.stub(:login) { 'some_token' }
    client.stub(:space) { space }
    client.stub(:organization) { organization }
    client.stub(:organization_by_name) { organization }
    client
  end

  let(:space) do
    space = mock(:space)
    space.stub(:name=)
    space.stub(:organization=)
    space.stub(:create!) { true }
    space
  end

  let(:organization) do
    org = mock(:org)
    org.stub(:create!) { true }
    org.stub(:name=)
    org
  end

  let(:config) do
    config = mock(:config)
    config.stub(:api_host) { 'mcapi.cloudfoundry.com' }
    config
  end

  before do
    CFoundry::Client.stub(:new) { cfoundry_client }
    VCAP::Micro::ConfigFile.stub(:new) { config }
  end

  it 'creates client to host name from config file' do
    CFoundry::Client.should_receive(:new).with('mcapi.cloudfoundry.com').and_return(cfoundry_client)
    subject.client
  end

  it 'logins with default username and password' do
    cfoundry_client.should_receive(:login).with(VCAP::Micro::Client::DEFAULT_USERNAME,
                                                VCAP::Micro::Client::DEFAULT_PASSWORD)
    subject.login
  end

  it 'creates organization' do
    cfoundry_client.organization.should_receive(:create!)
    subject.login
    subject.create_org
  end

  it 'creates space' do
    cfoundry_client.space.should_receive(:create!)
    subject.login
    subject.create_space
  end
end