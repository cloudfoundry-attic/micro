# This is to avoid circular dependencies with require.
module VCAP

  module Micro

    module Api

      module MediaType

        class Administrator < Engine::MediaType; end
        class DomainName < Engine::MediaType; end
        class MicroCloud < Engine::MediaType; end
        class NetworkHealth < Engine::MediaType; end
        class NetworkInterface < Engine::MediaType; end
        class Service < Engine::MediaType; end
        class ServiceList < Engine::MediaType; end

      end

    end

  end

end

Dir["#{File.dirname(__FILE__)}/media_type/**/*.rb"].each do |f|
  require f.sub(/.rb$/, '')
end
