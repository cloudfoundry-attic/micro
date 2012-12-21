module VCAP

  module Micro

    module Api

      module MediaType

        class Task < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-task+json'.freeze

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
          }.freeze

          def initialize(fields={})
            super fields

            @id = fields[:id]
            @state = fields[:state]
            @result = fields[:result]
          end

          attr_accessor :id
          attr_accessor :state
          attr_accessor :result
        end

      end

    end

  end

end
