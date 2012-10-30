require 'tempfile'

module VCAP

  module Micro

    module Api

      module Route

        # Draw a directed graph of the API using graphviz.
        module Graph

          def self.registered(app)

            app.get '/graph' do
              Tempfile.open('mcf_api') do |f|
                Engine::MediaType.graph.output(:png => f.path)

                content_type 'image/png'
                send_file f.path
              end
            end

          end

        end

      end

    end

  end

end
