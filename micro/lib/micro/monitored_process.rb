module VCAP

  module Micro

    # Monitored process.
    class MonitoredProcess

      def initialize(name)
        @name = name
      end

      # Stop the process.
      def stop
        Micro.shell_raiser("monit stop #{@name}")
      end

      # Check a bosh agent status and return true if this process is running.
      def running?(bosh_agent_status)
        bosh_agent_status[@name][:status][:message] == 'running'
      end

      attr_reader :name
    end

  end

end
