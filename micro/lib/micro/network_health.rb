require 'resolv'

module VCAP

  module Micro

    # All this to shorten the timeout.
    class ShortResolvDNS < Resolv::DNS
      attr_accessor :config
    end

    module ShortTimeout

      def generate_timeouts
        [5]
      end

    end

    # Network health checker.
    class NetworkHealth

      # Return true if a name can be resolved with the default resolver.
      def can_resolve_default?(options={})
        test_query = options[:test_query] || 'google.com'

        begin
          Resolv.getaddress(test_query)
          true
        rescue
          false
        end
      end

      # Return true if a name can be resolved with known public nameservers.
      def can_resolve_other?(options={})
        nameserver = options[:nameserver] || ['8.8.8.8', '8.8.4.4']
        test_query = options[:test_query] || 'google.com'

        ext_dns = ShortResolvDNS.new(:nameserver => nameserver)
        ext_dns.config.extend(ShortTimeout)

        begin
          ext_dns.getaddress(test_query)
          true
        rescue
          false
        end
      end

      # Return true if the host can be pinged.
      def ping?(host)
        %x{ping -c 1 #{host} > /dev/null 2>&1}
        $? == 0
      end

    end

  end

end
