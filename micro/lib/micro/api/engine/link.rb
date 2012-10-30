module VCAP

  module Micro

    module Api

      module Engine

        # A link to another state in a hypermedia API.
        class Link
          include JsonSerializable

          def initialize(fields={})
            @method = fields[:method]
            @href = fields[:href]
            @type = fields[:type]
          end

          attr_accessor :method
          attr_accessor :href
          attr_accessor :type
        end

      end

    end

  end

end
