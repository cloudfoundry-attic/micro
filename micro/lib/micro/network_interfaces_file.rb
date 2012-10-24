module VCAP

  module Micro

    class NetworkInterfacesFile

      # Return true if an interface is configured as DHCP.
      def self.is_interface_dhcp?(interface_name, interfaces_file)
        interfaces_file[/iface #{interface_name} inet dhcp/] ? true : false
      end

      def initialize(options={})
        @ip = options[:ip]
        @netmask = options[:netmask]
        @gateway = options[:gateway]
        @is_dhcp = options[:is_dhcp]
      end

      # Write the interface configuration to a file.
      def write(file='/etc/network/interfaces')
        open(file, 'w') do |f|
          f.write(to_s)
        end
      end

      # Build the heading.
      def head
        <<-eos
auto lo
iface lo inet loopback

auto eth0
eos
      end

      # Build the interface section.
      def iface
        if is_dhcp
          "iface eth0 inet dhcp\n"
        else
          <<-eos
iface eth0 inet static
address #{ip}
netmask #{netmask}
gateway #{gateway}
eos
        end
      end

      def to_s
        head + iface
      end

      attr_accessor :ip
      attr_accessor :netmask
      attr_accessor :gateway
      attr_accessor :is_dhcp
    end

  end

end
