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
        open(@path, 'w') do |f|
          f.flock(File::LOCK_EX)
          yield self  if block_given?
          f.write(YAML.dump(@spec))
          f.flock(File::LOCK_UN)
        end
      end

      def properties
        @spec['properties'] ||= {}
      end

      def cc
        properties['cc'] ||= {}
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
      end

      def domain
        properties['domain']
      end

      def domain=(domain)
        properties['domain'] = domain
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
    end

  end

end
