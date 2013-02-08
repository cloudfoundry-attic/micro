require 'spec_helper'

describe VCAP::Micro::Api::Route::NetworkInterface do
  include Rack::Test::Methods

  let(:app) { VCAP::Micro::Api::Server }
  let(:route_table) { fixture(:route_table) }
  let(:ifconfig) { fixture(:ifconfig) }
  let(:is_dhcp) { true }
  let(:dnsmasq) { ['someRandomNameServer'] }

  describe '.registered' do
  end

  describe '.get' do
    let(:action) { get '/network_interface' }

    before do
      VCAP::Micro::NetworkInterface.any_instance.should_receive(:`).with("ifconfig eth0") { ifconfig }
      VCAP::Micro::NetworkInterface.any_instance.should_receive(:`).with("route -n") { route_table }
      VCAP::Micro::Dnsmasq.stub_chain(:new, :read, :upstream_servers) { dnsmasq }
      VCAP::Micro::NetworkInterfacesFile.should_receive(:is_interface_dhcp?) { is_dhcp }
    end

    subject { action }

    context 'body' do
      subject { action; JSON.parse last_response.body }

      its(['_links']) do
        should eq(
                   "self" => {
                       "method" => "get",
                       "href" => "http://example.org/network_interface",
                       "type" => "application/vnd.vmware.mcf-network-interface+json"},
                   "microcloud" => {
                       "method" => "get",
                       "href" => "http://example.org/",
                       "type" => "application/vnd.vmware.mcf-micro-cloud+json"},
                   "network_health" => {
                       "method" => "get",
                       "href" => "http://example.org/network_health",
                       "type" => "application/vnd.vmware.mcf-network-health+json"},
                   "edit" => {
                       "method" => "post",
                       "href" => "http://example.org/network_interface",
                       "type" => "application/vnd.vmware.mcf-network-interface+json"}
               )
      end
      its(['name']) { should eq "eth0" }
      its(['ip_address']) { should eq "192.168.0.2" }
      its(['netmask']) { should eq "255.255.255.0" }
      its(['gateway']) { should eq "192.168.0.1" }
      its(['nameservers']) { should eq dnsmasq }
      its(['is_dhcp']) { should eq is_dhcp }
    end
  end

  describe '.post' do
    let(:valid_params) { {'ip_address' => '', 'netmask' => '', 'gateway' => '', 'nameservers' => '', 'is_dhcp' => true, 'name' => 'eth1'} }
    let(:params) { valid_params }
    let(:action) { post '/network_interface', params.to_json, 'CONTENT_TYPE' => 'application/vnd.vmware.mcf-network-interface+json' }

    before do
      VCAP::Micro.stub(:shell_raiser)
    end

    subject { action; last_response.body }

    context 'when the interface has no name' do
      let(:params) { valid_params.delete('name'); valid_params }

      before { VCAP::Micro::NetworkInterfacesFile.any_instance.stub(:write) }

      it 'should default to eth0' do
        VCAP::Micro.should_receive(:shell_raiser).with("ifdown eth0")
        subject
      end
    end
  end
end