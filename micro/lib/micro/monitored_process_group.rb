module VCAP

  module Micro

    # Monitored process group.
    class MonitoredProcessGroup

      def initialize(name, processes)
        @name = name
        @processes = processes
      end

      # Stop all processes in this group.
      def stop
        @processes.each(&:stop)
      end

      # Return true if this group is enabled.
      def enabled?
        ServiceConfig.new(@name).enabled?
      end

      # Return true if all processes in this group are running.
      def running?(bosh_agent_status)
        enabled? && @processes.all? { |p| p.running?(bosh_agent_status) }
      end

      def status_hash(bosh_agent_status)
        {
          :enabled => enabled?,
          :health => running?(bosh_agent_status) ? :ok : :failed
        }
      end

      attr_reader :name
      attr_reader :processes
    end

  end

end
