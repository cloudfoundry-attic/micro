module VCAP

  module Micro

    # Dnsmasq config file and process management.
    class Dnsmasq

      # Restart the dnsmasq server.
      def self.restart
        `service dnsmasq restart`
      end

      def initialize(domain, ip)
        @domain = domain
        @ip = ip

        @upstream_servers_path = '/etc/dnsmasq.d/server'

        @conf_path = '/etc/dnsmasq.conf'
        @enter_hook_path = '/etc/dhcp3/dhclient-enter-hooks.d/dnsmasq'
        @resolv_conf_path = '/etc/dhcp3/dhclient-enter-hooks.d/local_resolvconf'
      end

      # Generate the dnsmasq.conf file.
      def gen_conf
        "address=/#{domain}/#{ip}"
      end

      # Generate the dhclient enter hook file.
      def gen_enter_hook
        <<-eos
if [ "$reason" = "BOUND" ]; then
  echo "address=/#{domain}/$new_ip_address" > /etc/dnsmasq.conf

  for ns in $new_domain_name_servers
  do
    if [ -e "/var/vcap/micro/offline" ]; then
      echo "# server=$ns"
    else
      echo "server=$ns"
    fi
  done > /etc/dnsmasq.d/server

  service dnsmasq restart
fi
eos
      end

      # Generate the resolv.conf file.
      def gen_resolv_conf
        <<-eos
make_resolv_conf() {
  echo 'nameserver 127.0.0.1' > /etc/resolv.conf
}
eos
      end

      # Write all config files.
      def write
        open(conf_path, 'w') do |f|
          f.write(gen_conf)
        end

        open(enter_hook_path, 'w') do |f|
          f.write(gen_enter_hook)
        end

        open(resolv_conf_path, 'w') do |f|
          f.write(gen_resolv_conf)
        end

        self.class.restart
      end

      # Comment out all of the upstream DNS servers.
      def remove_upstream_servers
        Commenter.new(upstream_servers_path).comment
        self.class.restart
      end

      # Uncomment all of the upstream DNS servers.
      def restore_upstream_servers
        Commenter.new(upstream_servers_path).uncomment
        self.class.restart
      end

      attr_accessor :domain
      attr_accessor :ip

      attr_accessor :upstream_servers_path

      attr_accessor :conf_path
      attr_accessor :enter_hook_path
      attr_accessor :resolv_conf_path
    end

  end

end
