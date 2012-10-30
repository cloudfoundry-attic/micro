module VCAP

  module Micro

    # Current running network configuration.
    class NetworkInterface

      IP_RE = '(?:\d{1,3}\.){3}\d{1,3}'

      # Parse an ifconfig for one interface.
      #
      # Return a regex match object with named captures ip and netmask.
      def self.parse_ifconfig(ifconfig_output)
        %r{
          .*inet\ addr:(?<ip>#{IP_RE})
          .+
          Mask:(?<netmask>#{IP_RE})
          }x.match(ifconfig_output)
      end

      # Parse a route table (output of route -n).
      #
      # Return a regex match object with named capture default_route.
      def self.parse_route_table(route_table)
        %r{
          #{IP_RE}
          \s+
          (?<default_route>#{IP_RE})
          \s+
          #{IP_RE}
          \s+
          UG
          }x.match(route_table)
      end

      def initialize(name)
        @name = name
        @ip = nil
        @netmask = nil
        @gateway = nil
      end

      # Run commands, parse the output and load it into this instance.
      def load
        ifconfig_parsed = self.class.parse_ifconfig(`ifconfig #{name}`)
        if ifconfig_parsed
          @ip = ifconfig_parsed[:ip]
          @netmask = ifconfig_parsed[:netmask]
        end

        routes_parsed = self.class.parse_route_table(`route -n`)
        if routes_parsed
          @gateway = routes_parsed[:default_route]
        end

        self
      end

      # Restart this network interface.
      def restart
        Micro.shell_raiser(
          %Q{service network-interface restart INTERFACE="#{name}"})
      end

      attr_reader :name
      attr_reader :ip
      attr_reader :netmask
      attr_reader :gateway
    end

  end

end
