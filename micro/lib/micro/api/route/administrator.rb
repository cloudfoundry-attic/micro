module VCAP

  module Micro

    module Api

      module Route

        # Administrator routes.
        module Administrator

          def self.registered(app)

            app.get '/administrator' do
              administrator = MediaType::Administrator.new

              administrator.link(:self, request.url)
              administrator.link(:microcloud, url('/'))
              administrator.link(:edit, request.url)
            end

            app.post '/administrator' do
              expect MediaType::Administrator

              administrator = env['media_type_object']

              if administrator && administrator.password
                `echo "root:#{administrator.password}\nvcap:#{administrator.password}" | chpasswd`
              end
            end

          end

        end

      end

    end

  end

end
