module VCAP

  module Micro

    module Api

      module MediaType

        class MicroCloud < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-micro-cloud+json'.freeze

          Links = {
            :self => [:get,  self],
            :edit => [:post, self],
            :administrator => [:get, Administrator],
            :domain_name => [:get, DomainName],
            :network_health => [:get, NetworkHealth],
            :network_interface => [:get, NetworkInterface],
            :services => [:get, ServiceList],
          }.freeze

          def initialize(fields={})
            super fields

            @http_proxy = fields[:http_proxy]
            @internet_connected = fields[:internet_connected]
            @is_configured = fields[:is_configured]
            @is_powered_on = fields[:is_powered_on]
            @version = fields[:version]
          end

          attr_accessor :http_proxy
          attr_accessor :internet_connected
          attr_accessor :is_configured
          attr_accessor :is_powered_on
          attr_accessor :version
        end

      end

    end

  end

end
