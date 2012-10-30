module VCAP

  module Micro

    module Api

      module Route

        # Routes for network health.
        module NetworkHealth

          def self.registered(app)

            app.get '/network_health' do
              nh = Micro::NetworkHealth.new

              can_resolve_other = nh.can_resolve_other?

              default_gateway = Micro::NetworkInterface.new(
                'eth0').load.gateway

              network_health = MediaType::NetworkHealth.new(
                :reach_gateway => nh.ping?(default_gateway),
                :reach_internet => can_resolve_other || nh.ping?('8.8.8.8'),
                :resolve_default => nh.can_resolve_default?,
                :resolve_other => can_resolve_other
              )

              network_health.link(:microcloud, url('/'))
              network_health.link(:network_interface, url('/network_interface'))
            end

          end

        end

      end

    end

  end

end
