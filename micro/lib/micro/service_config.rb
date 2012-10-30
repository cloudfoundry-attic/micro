module VCAP

  module Micro

    # Service configuration.
    class ServiceConfig

      def initialize(name)
        @name = name
      end

      # Set the enabled status to true or false.
      #
      # Call a passed in block if the status is changed.
      def set_enabled(whether, &block)
        case whether
        when true then enable(&block)
        when false then disable(&block)
        end
      end

      # Return true if the service is enabled.
      def enabled?
        File.exist?(enabled_file)
      end

      # Enable this service.
      #
      # Call a passed in block if the status is changed.
      def enable
        prev = enabled?
        FileUtils.mv(disabled_file, enabled_file)
        yield self  if enabled? != prev
      end

      # Return true if this service is disabled.
      def disabled?
        !enabled?
      end

      # Disable this service.
      #
      # Call a passed in block if the status is changed.
      def disable
        prev = enabled?
        FileUtils.mv(enabled_file, disabled_file)
        yield self  if enabled? != prev
      end

      def enabled_file
        "/var/vcap/monit/job/micro.micro_#{@name}.monitrc"
      end

      def disabled_file
        "/var/vcap/monit/job/micro.micro_#{@name}.disabled"
      end

      attr_accessor :name
    end

  end

end
