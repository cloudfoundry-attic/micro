require 'micro/network_interface'

module VCAP

  module Micro

    # Dnsmasq config file and process management.
    class Dnsmasq

      # Restart the dnsmasq server.
      def self.restart
        `service dnsmasq restart`
      end

      def initialize(options={})
        @domain = options[:domain]
        @ip = options[:ip]

        @upstream_servers = options[:upstream_servers] || []

        @upstream_servers_path =
          options[:upstream_servers_path] || '/etc/dnsmasq.d/server'
        @conf_path = options[:conf_path] || '/etc/dnsmasq.conf'
        @enter_hook_path =
          options[:enter_hook_path] ||
          '/etc/dhcp3/dhclient-enter-hooks.d/dnsmasq'
        @resolv_conf_path = options[:resolv_conf_path] ||
          '/etc/dhcp3/dhclient-enter-hooks.d/local_resolvconf'
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

      # Generate the upstream nameservers configuration file.
      def gen_upstream_servers
        upstream_servers.to_a.map { |s| "server=#{s}" }.join("\n") + "\n"
      end

      # Read the domain and ip configuration from the config files.
      def read_domain_ip
        open(conf_path) do |f|
          m = f.read.match(%r{address=/([\w.-]+)/(#{NetworkInterface::IP_RE})})
          if m
            @domain = m[1]
            @ip = m[2]
          end
        end
      end

      # Read upstream servers from config files.
      def read_upstream_servers
        servers = []

        if File.exist?(upstream_servers_path)
          open(upstream_servers_path).each do |line|
            server = line[/^server=(#{NetworkInterface::IP_RE})$/, 1]
            servers << server  if server
          end
        end

        @upstream_servers = servers
      end

      # Read configuration from config files.
      def read
        read_domain_ip
        read_upstream_servers

        self
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

        open(upstream_servers_path, 'w') do |f|
          f.write(gen_upstream_servers)
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
      attr_accessor :upstream_servers

      attr_accessor :upstream_servers_path
      attr_accessor :conf_path
      attr_accessor :enter_hook_path
      attr_accessor :resolv_conf_path
    end

  end

end
