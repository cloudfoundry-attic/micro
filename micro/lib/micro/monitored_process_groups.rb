require 'yaml'

require 'micro/monitored_process'
require 'micro/monitored_process_group'

module VCAP

  module Micro

    # Monitored process groups.
    class MonitoredProcessGroups

      def initialize(options={})
        @groups = {}

        @path = options[:path] || '/var/vcap/jobs/micro/config/monit.yml'
      end

      # Read process group data from the filesystem.
      def read
        groups = {}

        YAML.load_file(@path).each do |k,v|
          groups[k] = MonitoredProcessGroup.new(
            k, v.map { |p| MonitoredProcess.new(p) })
        end

        @groups = groups

        self
      end

      # Get a group by name.
      def group(name)
        @groups[name]
      end

      # Return the status of monitored process groups.
      #
      # { group => { :enabled => true, :health => :ok } }
      def status(bosh_agent_status)
        @groups.inject({}) { |memo, (name, group)|
          memo[name] = group.status_hash(bosh_agent_status); memo }
      end

    end

  end

end
