module VCAP

  module Micro

    module Api

      module MediaType

        class ServiceList < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-service-list+json'.freeze

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
          }.freeze

          def initialize(fields={})
            super fields

            @services = fields[:services]
          end

          attr_accessor :services
        end

      end

    end

  end

end
