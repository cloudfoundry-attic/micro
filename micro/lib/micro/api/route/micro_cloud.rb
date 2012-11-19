module VCAP

  module Micro

    module Api

      module Route

        # Routes for Micro Cloud.
        module MicroCloud

          def self.registered(app)

            app.get '/' do
              spec = ApplySpec.new.read
              config_file = ConfigFile.new

              m = MediaType::MicroCloud.new(
                :http_proxy => spec.http_proxy,
                :internet_connected => InternetConnection.new.connected?,
                :is_configured => config_file.configured?,
                :is_powered_on => true,
                :version => VCAP::Micro::Version::VERSION,
              )

              m.link(:self, request.url)
              m.link(:edit, request.url)
              m.link(:administrator, url('administrator'))
              m.link(:'domain_name', url('domain_name'))
              m.link(:'network_health', url('network_health'))
              m.link(:'network_interface', url('network_interface'))
              m.link(:'services', url('services'))
            end

            app.post '/' do
              expect MediaType::MicroCloud

              micro_cloud = env['media_type_object']

              if micro_cloud
                if micro_cloud.http_proxy
                  spec = ApplySpec.new.read
                  spec.write do |s|
                    s.http_proxy = micro_cloud.http_proxy
                  end

                  settings.bosh.restart_services
                end

                if micro_cloud.internet_connected == false
                  InternetConnection.new.set_disconnected
                elsif micro_cloud.internet_connected == true
                  InternetConnection.new.set_connected
                end

                if micro_cloud.is_powered_on == false
                  settings.bosh.stop_services_and_wait
                  Micro.shell_raiser('poweroff')
                end
              end
            end

          end

        end

      end

    end

  end

end
