require 'cfoundry'

module VCAP
  module Micro
    class Client

      ORG_NAME = 'micro_org'
      SPACE_NAME = 'micro_space'
      DEFAULT_USERNAME = 'micro@vcap.me'
      DEFAULT_PASSWORD = 'micro'
      DOCS_APP_NAME = 'docs'

      def logger
        Console.logger
      end

      def micro_config
        @micro_config ||= VCAP::Micro::ConfigFile.new
      end

      def client
        @client ||= CFoundry::Client.new(target)
      end

      def v2?
        client.is_a?(CFoundry::V2::Client)
      end

      def target
        @target ||= micro_config.api_host
      end

      def login
        @token = client.login(DEFAULT_USERNAME, DEFAULT_PASSWORD)
      rescue => e
        logger.error("Failed to login to create org and space: #{e.message}")
      end

      def docs_app_path
        File.expand_path('../../../cf-docs', __FILE__)
      end

      def space
        @space ||= find_space || create_space
      end

      def find_space
        return unless v2?
        client.space_by_name(SPACE_NAME)
      end

      def create_space
        return unless v2?
        space = client.space
        space.name = SPACE_NAME
        space.organization = organization
        space.create!
        space
      rescue CFoundry::SpaceNameTaken
        logger.warn("Space '#{SPACE_NAME}' already exists")
      end

      def organization
        @organization ||= find_org || create_org
      end

      def find_org
        return unless v2?
        client.organization_by_name(ORG_NAME)
      end

      def create_org
        return unless v2?
        org = client.organization
        org.name = ORG_NAME
        org.create!
        org
      rescue CFoundry::OrganizationNameTaken
        logger.warn("Organization '#{ORG_NAME}' already exists")
      end

      def domain
        return unless v2?
        @domain ||= space.domain_by_name(micro_config.subdomain)
      end

      def find_route(host_name)
        return unless v2?
        client.routes_by_host(host_name, :depth => 0).find do |r|
          r.domain = domain
        end
      end

      def create_route(host_name)
        return unless v2?
        route = client.route
        route.host = host_name
        route.space = space
        route.domain = domain
        route.create!
        route
      rescue CFoundry::RouteHostTaken
        logger.warn("Host '#{host_name}' already exists")
      end

      def push_app(manifest)
        app = client.app_by_name(manifest[:name])
        unless app
          app = client.app
          app.name = manifest[:name]
          app.space = space if v2?
          app.total_instances = 1

          app.framework = client.framework_by_name(manifest[:framework])
          app.runtime = client.runtime_by_name(manifest[:runtime])

          app.command = manifest[:command] if manifest[:command]
          app.create!
        end

        logger.info('Mapping url')
        if v2?
          new_route = find_route(manifest[:name]) || create_route(manifest[:name])
          app.add_route(new_route)
        else
          app.urls << "#{manifest[:name]}.#{micro_config.subdomain}"
          app.update!
        end

        logger.info('Uploading docs app')
        app.upload(manifest[:path])

        logger.info('Starting docs app')
        app.start!
      end

      def create_org_and_space
        return unless v2?
        login
        create_org
        create_space
      end

      def push_docs_app
        login
        if File.exists?(docs_app_path)
          logger.info('Pushing docs app #{docs_app_path}')
          push_app(
            :path => docs_app_path,
            :name => DOCS_APP_NAME,
            :framework => 'standalone',
            :runtime => 'ruby19',
            :command => 'bundle exec middleman server -p $VCAP_APP_PORT'
          )
        else
          logger.warn('Could not find docs app')
        end
      end
    end
  end
end