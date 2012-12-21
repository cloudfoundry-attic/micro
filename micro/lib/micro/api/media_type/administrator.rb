module VCAP

  module Micro

    module Api

      module MediaType

        class Administrator < Engine::MediaType
          MEDIA_TYPE = 'application/vnd.vmware.mcf-administrator+json'.freeze

          Links = {
            :self => [:get, self],
            :microcloud => [:get, MicroCloud],
            :edit => [:post, self],
          }.freeze

          def initialize(fields={})
            super fields

            @email = fields[:email]
            @password = fields[:password]
          end

          attr_accessor :email
          attr_accessor :password
        end

      end

    end

  end

end
