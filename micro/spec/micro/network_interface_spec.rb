require 'spec_helper'

describe VCAP::Micro::NetworkInterface do
  let(:route_table) { fixture(:route_table) }
  let(:ifconfig_output) { fixture(:ifconfig) }

  describe '#parse_ifconfig' do
    context 'ifconfig is valid' do
      subject { VCAP::Micro::NetworkInterface.parse_ifconfig(ifconfig_output) }
      its([:ip]) { should == '192.168.0.2' }
      its([:netmask]) { should == '255.255.255.0' }
    end

    context 'ifconfig is invalid' do
      subject { VCAP::Micro::NetworkInterface.parse_ifconfig('foo 192.168.0.2') }
      it { should be_nil }
    end
  end

  describe '#parse_route_table' do
    context 'route table is valid' do
      subject { VCAP::Micro::NetworkInterface.parse_route_table(route_table) }
      its([:default_route]) { should == '192.168.0.1' }
    end

    context 'route table is invalid' do
      subject { VCAP::Micro::NetworkInterface.parse_route_table('foo 192.168.0.2') }
      it { should be_nil }
    end
  end

  describe '#load' do
    it 'runs a shell command to ifup' do

    end
  end
end
