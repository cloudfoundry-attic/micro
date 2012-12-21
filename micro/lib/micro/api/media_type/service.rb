module VCAP

  module Micro

    module Api

      module MediaType

        class Service < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-service+json'.freeze

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
            :edit => [:post, self],
            :services => [:get, ServiceList],
          }.freeze

          def initialize(fields={})
            super fields

            @name = fields[:name]
            @enabled = fields[:enabled]
            @health = fields[:health]
          end

          attr_accessor :name
          attr_accessor :enabled
          attr_accessor :health
        end

      end

    end

  end

end
