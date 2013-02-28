module VCAP
  module Micro
    class BoshWrapper

      # Wrapper for Bosh agent and agent client.
      def initialize(settings={})
        @group = settings.delete('group') || Bosh::Agent::BOSH_APP_GROUP

        default_settings = {
          "configure" => true,
          "logging" => {
            "level" => "DEBUG",
            "file" => "/var/vcap/sys/log/micro/agent.log"
          },
          "agent_id" => "micro",
          "base_dir" => "/var/vcap",
          "platform_name" => "microcloud",
          "blobstore_options" => {
            "blobstore_path" => "/var/vcap/micro_bosh/data/cache"
          },
          "blobstore_provider" => "local",
          "infrastructure_name" => "vsphere"
        }

        Bosh::Agent::Config.setup(default_settings.merge(settings))
      end

      # Get the current status of services.
      def status
        Bosh::Agent::Monit.retry_monit_request do |client|
          client.status(:group => @group)
        end
      end

      # Start all services.
      def start_services
        Bosh::Agent::Monit.start_services(60)
      end

      # Return true if a service is started.
      #
      # service_data is the result of status for a single service.
      def service_started?(service_data)
        service_data[:monitor] == :yes &&
          service_data[:status][:message] == 'running'
      end

      # Return true if all services are started.
      def all_started?(some_status)
        some_status.all? { |_, data| service_started?(data) }
      end

      # Sleep until all services are started.
      def wait_for_services_started(wait=1)
        until all_started?(status)
          sleep wait
        end
      end

      # Start all services and wait until they are all started.
      def start_services_and_wait
        start_services
        wait_for_services_started
      end

      # Stop all services.
      def stop_services
        Bosh::Agent::Monit.stop_services(60)
      end

      # Return true if a service is stopped.
      #
      # service_data is the result of status for a single service.
      def service_stopped?(service_data)
        service_data[:monitor] == :no
      end

      # Return true if all services are stopped.
      def all_stopped?(some_status)
        some_status.all? { |_, data| service_stopped?(data) }
      end

      # Sleep until all services are stopped.
      def wait_for_services_stopped(wait=1)
        until all_stopped?(status)
          sleep wait
        end
      end

      # Stop all services and wait until they are all stopped.
      def stop_services_and_wait
        stop_services
        wait_for_services_stopped
      end

      # Restart all services.
      def restart_services
        stop_services_and_wait
        # start_services_and_wait
        start_services
      end

      # Create an HTTP client for the Bosh agent.
      def agent_client
        Bosh::Agent::Client.create('http://localhost:6969',
          'user' => 'vcap',
          'password' => 'vcap')
      end

      # Apply an apply spec using the Bosh agent client.
      def apply_spec(spec)
        agent_client.run_task(:apply, spec)
        restart_services
        # client = Client.new
        # client.create_org_and_space
        # client.push_docs_app
      end

      # Reload monitor.
      def reload_monitor
        Bosh::Agent::Monit.reload
      end

    end

  end

end
