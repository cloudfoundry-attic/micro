require 'yaml'

module VCAP

  module Micro

    # Micro Cloud Foundry bosh apply spec.
    class ApplySpec

      DEFAULT_PATH = '/var/vcap/micro/apply_spec.yml'

      def initialize(path=DEFAULT_PATH)
        @path = path
        @spec = {}
      end

      # Load this apply spec from a YAML file.
      def read
        @spec = YAML.load_file(@path)

        self
      end

      # Write this apply spec to a YAML file.
      #
      # If a block is passed in, the apply spec will be yielded so that
      # changes can be made before writing.
      def write
        randomize_passwords

        yield self  if block_given?
        output = YAML.dump(@spec)

        open(@path, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.write(output)
          f.flock(File::LOCK_UN)
        end
      end

      # Randomize the passwords.
      #
      # Note that this only sets password that are not already set.
      def randomize_passwords
        Settings.randomize_passwords(properties)
      end

      def properties
        @spec['properties'] ||= {}
      end

      def cc_props
        properties['cc_props'] || 'cc'
      end

      def cc
        properties[cc_props] ||= {}
      end

      def env
        properties['env'] ||= {}
      end

      def admin
        admins[0]
      end

      def admin=(admin)
        self.admins = [admin]
      end

      def admins
        cc['admins']
      end

      def admins=(admins)
        cc['admins'] = admins
        cc['bootstrap_admin_email'] = admins[0]
      end

      def domain
        properties['domain']
      end

      def domain=(domain)
        properties['domain'] = domain
        cc_host = cc_props == "ccng" ? "ccng" : "api"
        cc['srv_api_uri'] = "http://#{cc_host}.#{domain}/"
      end

      def http_proxy
        env['http_proxy']
      end

      def http_proxy=(http_proxy)
        if http_proxy.to_s.empty?
          env.delete('http_proxy')
          env.delete('https_proxy')
          env.delete('no_proxy')
        else
          env['http_proxy'] = http_proxy
          env['https_proxy'] = http_proxy
          env['no_proxy'] = ".#{domain},127.0.0.1/8,localhost"
        end
      end

      attr_accessor :path
      attr_accessor :spec
    end

  end

end
