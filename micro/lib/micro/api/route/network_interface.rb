require 'micro/network_interfaces_file'

module VCAP

  module Micro

    module Api

      module Route

        # Routes for the network interface.
        module NetworkInterface

          def self.registered(app)

            app.get '/network_interface' do
              interface = Micro::NetworkInterface.new('eth0').load

              network_interface = MediaType::NetworkInterface.new(
                :name => interface.name,
                :ip_address => interface.ip,
                :netmask => interface.netmask,
                :gateway => interface.gateway,
                :nameservers => Dnsmasq.new.read.upstream_servers,
                :is_dhcp => NetworkInterfacesFile.is_interface_dhcp?(
                  'eth0', File.read('/etc/network/interfaces'))
              )

              network_interface.link(:self, request.url)
              network_interface.link(:microcloud, url('/'))
              network_interface.link(:network_health, url('network_health'))
              network_interface.link(:edit, request.url)
            end

            app.post '/network_interface' do
              expect MediaType::NetworkInterface

              network_interface = env['media_type_object']

              network_interface_file = Micro::NetworkInterfacesFile.new(
                :ip => network_interface.ip_address,
                :netmask => network_interface.netmask,
                :gateway => network_interface.gateway,
                :is_dhcp => network_interface.is_dhcp
              )

              network_interface_file.write

              Micro::NetworkInterface.new(network_interface.name).restart

              if network_interface_file.static?
                dnsmasq = Dnsmasq.new.read
                dnsmasq.ip = network_interface.ip_address
                if network_interface.nameservers
                  dnsmasq.upstream_servers = network_interface.nameservers
                end
                dnsmasq.write
                Dnsmasq.restart
              end
            end

          end

        end

      end

    end

  end

end
