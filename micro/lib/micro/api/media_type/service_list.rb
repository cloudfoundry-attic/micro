module VCAP

  module Micro

    module Api

      module MediaType

        class ServiceList < Engine::MediaType
          MediaType = 'application/vnd.vmware.mcf-service-list+json'

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
          }

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
