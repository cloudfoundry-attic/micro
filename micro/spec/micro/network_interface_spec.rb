require 'spec_helper'

describe VCAP::Micro::NetworkInterface do

  describe '#parse_ifconfig' do

    context 'ifconfig is valid' do

      subject {
        ifconfig_output = <<-eos
eth0      Link encap:Ethernet  HWaddr fe:fd:ad:ff:e7:a8
          inet addr:192.168.0.2  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::fcfd:adff:feff:e7a8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13162130 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6961576 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1389809325 (1.3 GB)  TX bytes:28566890200 (28.5 GB)
          Interrupt:48
eos
        VCAP::Micro::NetworkInterface.parse_ifconfig(ifconfig_output)
      }

      it { subject[:ip].should == '192.168.0.2' }
      it { subject[:netmask].should == '255.255.255.0' }
    end

    context 'ifconfig is invalid' do

      subject {
        VCAP::Micro::NetworkInterface.parse_ifconfig('foo')
      }

      it { should be_nil }
    end

  end

  describe '#parse_route_table' do

    context 'route table is valid' do

      subject {
        route_table = <<-eos
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.0.1   0.0.0.0         UG    100    0        0 eth0
192.168.0.0   0.0.0.0         255.255.255.0   U     0      0        0 eth0
eos
        VCAP::Micro::NetworkInterface.parse_route_table(route_table)
      }

      it { subject[:default_route].should == '192.168.0.1' }
    end

    context 'route table is invalid' do

      subject {
        VCAP::Micro::NetworkInterface.parse_route_table('foo')
      }

      it { should be_nil }
    end

  end

end
