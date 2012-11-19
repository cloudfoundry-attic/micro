module VCAP

  module Micro

    module Api

      module Route

        # Administrator routes.
        module Administrator

          def self.registered(app)

            app.get '/administrator' do
              config_file = ConfigFile.new

              administrator = MediaType::Administrator.new(
                :email => config_file.admin_email,
              )

              administrator.link(:self, request.url)
              administrator.link(:microcloud, url('/'))
              administrator.link(:edit, request.url)
            end

            app.post '/administrator' do
              expect MediaType::Administrator

              administrator = env['media_type_object']

              if administrator
                if administrator.password
                  `echo "root:#{administrator.password}\nvcap:#{administrator.password}" | chpasswd`
                end

                if !administrator.email.to_s.empty?
                  if !Micro::InternetConnection.new.connected?
                    config_file = ConfigFile.new
                    config_file.write do |c|
                      c.admin_email = administrator.email
                    end

                    spec = ApplySpec.new.read
                    spec.write do |s|
                      s.admin = administrator.email
                    end

                    settings.bosh.apply_spec(spec.spec)
                  else
                    halt 400, 'Cannot set administrator email when connected to the internet'
                  end
                end
              end
            end

          end

        end

      end

    end

  end

end
