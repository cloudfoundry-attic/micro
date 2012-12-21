module VCAP
  module Micro
    module Api
      module Engine
        module Rack
          class Logger
            def initialize(app, log_file)
              @app = app
              @log_file = log_file
            end

            def call(env)
              env['rack.errors']  = @log_file
              @app.call(env)
            end
          end
        end
      end
    end
  end
end
