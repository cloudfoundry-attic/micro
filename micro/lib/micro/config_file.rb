module VCAP

  module Micro

    # Micro Cloud config file.
    class ConfigFile

      DEFAULT_PATH = '/var/vcap/micro/micro.json'.freeze

      def initialize(path=DEFAULT_PATH)
        @path = path
        @config = {}
        read  if configured?
      end

      def exists?
        File.exist?(@path)
      end

      alias_method :configured?, :exists?

      # Load this config file from a JSON file.
      def read
        open(@path) do |f|
          @config = JSON.parse(f.read)
        end

        self
      end

      # Write this config file to a JSON file.
      #
      # If a block is passed in, the config file will be yielded so that
      # changes can be made before writing.
      def write
        yield self  if block_given?
        output = JSON.generate(@config)

        open(@path, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.write(output)
          f.flock(File::LOCK_UN)
        end

        self
      end

      def subdomain
        "#{name}.#{cloud}"
      end

      def admin_emails
        @config.fetch('admins', [])
      end

      def admin_emails=(admin_emails)
        @config['admins'] = admin_emails
      end

      def admin_email
        admin_emails[0]
      end

      def admin_email=(email)
        self.admin_emails = [email]
      end

      def api_host
        @config['api_host'] ||= 'mcapi.cloudfoundry.com'
      end

      def api_host=(api_host)
        @config['api_host'] = api_host
      end

      def cloud
        @config['cloud']
      end

      def cloud=(cloud)
        @config['cloud'] = cloud
      end

      def ip
        @config['ip']
      end

      def ip=(ip)
        @config['ip'] = ip
      end

      def name
        @config['name']
      end

      def name=(name)
        @config['name'] = name
      end

      def token
        @config['token']
      end

      def token=(token)
        @config['token'] = token
      end

      attr_accessor :path
    end

  end

end
