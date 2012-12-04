module VCAP

  module Micro

    module Api

      module Route

        # Route to list services and their status.
        module ServiceList

          def self.registered(app)

            app.get '/services' do
              groups = MonitoredProcessGroups.new.read

              services = []

              groups.status(BoshWrapper.new.status).each do |name, data|

                service = MediaType::Service.new(
                  :name => name,
                  :enabled => data[:enabled],
                  :health => data[:health]
                )

                service.link(:self, url("/service/#{name}"))
                service.link(:edit, url("/service/#{name}"))

                services << service
              end

              service_list = MediaType::ServiceList.new(
                :services => services,
              )

              service_list.link(:self, request.url)
              service_list.link(:microcloud, url('/'))
            end

          end

        end

      end

    end

  end

end
