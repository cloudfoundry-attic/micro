require 'spec_helper'

describe VCAP::Micro::Client do
  subject { VCAP::Micro::Client.new }

  let(:cfoundry_client) do
    client = mock(:cfoundry_client)
    client.stub(:is_a?).with(CFoundry::V2::Client) { v2? }
    client.stub(:login) { 'some_token' }
    client.stub(:space) { v2? ? space : fail("v2 only") }
    client.stub(:organization) { v2? ? organization : fail("v2 only") }
    client.stub(:route) { route }
    client.stub(:app) { app }
    client.stub(:space_by_name) { v2? ? space : fail("v2 only") }
    client.stub(:organization_by_name) { v2? ? organization : fail("v2 only") }
    client.stub(:framework_by_name) { |name| name }
    client.stub(:runtime_by_name) { |name| name }
    client.stub(:app_by_name) { nil }
    client.stub(:routes_by_host) { v2? ? [route] : fail("v2 only") }
    client
  end

  let(:space) do
    space = mock(:space)
    space.stub(:name=)
    space.stub(:domain_by_name)
    space.stub(:organization=)
    space.stub(:create!) { fail("v2 only") unless v2? }
    space
  end

  let(:organization) do
    org = mock(:org)
    org.stub(:create!) { fail("v2 only") unless v2? }
    org.stub(:name=)
    org
  end

  let(:route) do
    route = mock(:route)
    route.stub(:host=)
    route.stub(:space=)
    route.stub(:domain=)
    route.stub(:create!) { fail("v2 only") unless v2? }
    route
  end

  let(:app) do
    app = mock(:app)
    app.stub(:name=)
    app.stub(:space=)
    app.stub(:total_instances=)
    app.stub(:framework=)
    app.stub(:runtime=)
    app.stub(:command=)
    app.stub(:add_route) { fail("v2 only") unless v2? }
    app.stub(:urls) { v2? ? fail("v2 only") : [] }
    app.stub(:update!)
    app.stub(:create!) { true }
    app.stub(:upload) { true }
    app.stub(:start!) { true }
    app
  end

  let(:config) do
    config = mock(:config)
    config.stub(:api_host) { 'mcapi.cloudfoundry.com' }
    config.stub(:subdomain) { 'cloudfoundry.com' }
    config
  end

  let(:v2?) { true }

  let(:app_name) { 'app_name' }
  let(:framework) { 'sinatra' }
  let(:runtime) { 'ruby19' }
  let(:upload_path) { '/some/path' }
  let(:manifest) do
    {
      :path => upload_path,
      :name => app_name,
      :framework => framework,
      :runtime => runtime
    }
  end

  before do
    CFoundry::Client.stub(:new) { cfoundry_client }
    VCAP::Micro::ConfigFile.stub(:new) { config }
    VCAP::Micro::ApplySpec.stub(:default_path) { "spec/assets/apply_spec.yml" }
  end

  it 'creates client to host name from config file' do
    CFoundry::Client.should_receive(:new).with('http://api.englund.cloudfoundry.me').and_return(cfoundry_client)
    subject.client
  end

  it 'logins with default username and password' do
    cfoundry_client.should_receive(:login).with(VCAP::Micro::Client::DEFAULT_USERNAME,
                                                VCAP::Micro::Client::DEFAULT_PASSWORD)
    subject.login
  end

  context 'when v2' do
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

    it 'pushes an app according to manifest' do
      cfoundry_client.route.should_receive(:host=).with(app_name)
      cfoundry_client.route.should_receive(:create!)
      cfoundry_client.app.should_receive(:name=).with(app_name)
      cfoundry_client.app.should_receive(:framework=).with(framework)
      cfoundry_client.app.should_receive(:runtime=).with(runtime)
      cfoundry_client.app.should_receive(:create!)
      cfoundry_client.app.should_receive(:add_route)
      cfoundry_client.app.should_receive(:upload).with(upload_path)
      cfoundry_client.app.should_receive(:start!)

      subject.push_app(manifest)
    end
  end

  context 'when v1' do
    let(:v2?) { false }

    it 'does not create space' do
      cfoundry_client.should_not_receive(:space)
      subject.create_space
    end

    it 'does not create org' do
      cfoundry_client.should_not_receive(:organization)
      subject.create_org
    end

    it 'adds urls when creating app' do
      cfoundry_client.app.should_receive(:urls)
      cfoundry_client.app.should_receive(:update!)
      subject.push_app(manifest)
    end

    it 'does not add route when creating app' do
      cfoundry_client.app.should_not_receive(:add_route)
      subject.push_app(manifest)
    end

    it 'does not add space to app when creating app' do
      cfoundry_client.app.should_not_receive(:space=)
      subject.push_app(manifest)
    end
  end

  it 'pushes docs app' do
    subject.stub(:docs_app_path) { __FILE__ }
    subject.should_receive(:push_app).with({
      :path => __FILE__,
      :name => VCAP::Micro::Client::DOCS_APP_NAME,
      :framework => 'standalone',
      :runtime => 'ruby19',
      :command => 'bundle exec middleman server -p $VCAP_APP_PORT'
    })

    subject.push_docs_app
  end
end