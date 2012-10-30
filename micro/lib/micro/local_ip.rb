require 'socket'

module VCAP

  module Micro

    module_function

    # Return the first non-loopback IPv4 address of this machine.
    def local_ip
      Socket.ip_address_list.find{
        |a| a.ipv4? && !a.ipv4_loopback? }.ip_address
    end

  end

end
