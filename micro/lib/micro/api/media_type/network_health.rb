module VCAP

  module Micro

    module Api

      module MediaType

        class NetworkHealth < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-network-health+json'.freeze

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
            :network_interface => [:get, NetworkInterface],
          }.freeze

          def initialize(fields={})
            super fields

            @reach_gateway = fields[:reach_gateway]
            @reach_internet = fields[:reach_internet]
            @resolve_default = fields[:resolve_default]
            @resolve_other = fields[:resolve_other]
          end

          attr_accessor :reach_gateway
          attr_accessor :reach_internet
          attr_accessor :resolve_default
          attr_accessor :resolve_other
        end

      end

    end

  end

end
