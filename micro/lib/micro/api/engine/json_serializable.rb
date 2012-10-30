module VCAP

  module Micro

    module Api

      module Engine

        module JsonSerializable

          # Convert to JSON by serializing a hash of the instance variables.
          def to_json(*a)
            Hash[instance_variables.map {
              |iv| [iv[1..-1], instance_variable_get(iv)] }].to_json(*a)
          end

        end

      end

    end

  end

end
