module VCAP

  module Micro

    module Api

      module Engine

        module ExpectHelper

          # Return HTTP 415 Unsupported media type unless the content
          # type header matches the media type of the expected class.
          def expect(*media_types)
            unless media_types.map { |mt| mt::MEDIA_TYPE }.include?(request.content_type)
              halt 415
            end
          end

        end

      end

    end

  end

end
