module VCAP

  module Micro

    module Api

      module Route

        # Routes for individual service status.
        module Service

          def self.registered(app)

            app.get '/service/:name' do |name|
              groups = MonitoredProcessGroups.new.read

              group_status = groups.group(name).status_hash(
                BoshWrapper.new.status)

              service = MediaType::Service.new(
                :name => name,
                :enabled => group_status[:enabled],
                :health => group_status[:health]
                )

              service.link(:self, url("/service/#{name}"))
              service.link(:edit, url("/service/#{name}"))
              service.link(:services, url("/services"))
            end

            app.post '/service/:name' do |name|
              expect MediaType::Service

              service = env['media_type_object']

              if service
                ServiceConfig.new(name).set_enabled(service.enabled) do |sc|
                  if sc.disabled?
                    MonitoredProcessGroups.new.read.group(name).stop
                  end

                  bosh = BoshWrapper.new
                  bosh.reload_monitor
                  bosh.start_services
                end
              end

              200
            end

          end

        end

      end

    end

  end

end
