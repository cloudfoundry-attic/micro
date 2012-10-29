require 'fileutils'

require 'micro/dnsmasq'

module VCAP

  module Micro

    # Manage the Micro Cloud's internet-connection (online/offline) status.
    #
    # Perform side effects that need to happen when state changes.
    class InternetConnection

      DEFAULT_OFFLINE_FILE = '/var/vcap/micro/offline'

      def initialize(offline_file=DEFAULT_OFFLINE_FILE)
        @offline_file = offline_file
      end

      # Return true if the Micro Cloud is connected to the internet.
      def connected?
        !File.exist?(@offline_file)
      end

      # Tell the Micro Cloud that it is currently connected to the internet.
      def set_connected
        FileUtils.rm_f(@offline_file)
        Dnsmasq.new.restore_upstream_servers
      end

      # Tell the Micro Cloud that it is currently not connected to the
      # internet.
      def set_disconnected
        FileUtils.touch(@offline_file)
        Dnsmasq.new.remove_upstream_servers
      end

    end

  end

end
