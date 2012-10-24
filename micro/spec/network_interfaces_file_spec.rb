require 'tempfile'

require 'micro/network_interfaces_file'

describe VCAP::Micro::NetworkInterfacesFile do

  describe '#is_interface_dhcp?' do

    context 'interface is dhcp' do

      subject {
        interfaces = <<-eos
auto lo
iface lo inet loopback

auth eth0
iface eth0 inet dhcp
eos
        VCAP::Micro::NetworkInterfacesFile.is_interface_dhcp?(
          'eth0', interfaces)
      }

      it { should be_true }
    end

    context 'interface is not dhcp' do

      subject {
        interfaces = <<-eos
auto lo
iface lo inet loopback

auth eth0
iface eth0 inet dhcp
eos
        VCAP::Micro::NetworkInterfacesFile.is_interface_dhcp?(
          'eth1', interfaces)
      }

      it { should be_false }
    end

  end

  describe '.to_s' do

    context 'interface is dhcp' do

      subject {
        VCAP::Micro::NetworkInterfacesFile.new(:is_dhcp => true)
      }

      its(:to_s) { should == <<-eos
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
eos
      }

    end

    context 'interface is static' do

      subject {
        VCAP::Micro::NetworkInterfacesFile.new(
          :ip => '192.168.0.2',
          :netmask => '255.255.255.0',
          :gateway => '192.168.0.1',
          )
      }

      its(:to_s) { should == <<-eos
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.0.2
netmask 255.255.255.0
gateway 192.168.0.1
eos
      }

    end

  end

  describe '.write' do

    it 'should write to a file' do
      nif = VCAP::Micro::NetworkInterfacesFile.new(:is_dhcp => true)

      temp = Tempfile.new('network_interfaces_file')
      begin
        nif.write(temp.path)
        temp.flush

        open(temp.path) do |f|
          f.read.should == <<-eos
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
eos
        end
      ensure
        temp.close
      end
    end

  end

end
