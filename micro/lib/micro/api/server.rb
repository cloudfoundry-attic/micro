module VCAP

  module Micro

    module Api

      # Base for Sinatra app.
      #
      # Automatically loads all routes in the Route module.
      class Server < Sinatra::Base
        enable :logging
        disable :show_exceptions

        helpers Engine::ExpectHelper

        Route.constants.each do |c|
          o = Route.const_get(c)
          register o  if o.is_a?(Module)
        end

      end

    end

  end

end
