require 'cfoundry'

module VCAP
  module Micro
    class Client

      ORG_NAME = 'micro_org'
      SPACE_NAME = 'micro_space'
      DEFAULT_USERNAME = 'micro@vcap.me'
      DEFAULT_PASSWORD = 'micro'

      def logger
        Console.logger
      end

      def client
        logger.info(target)
        @client ||= CFoundry::Client.new(target)
      end

      def target
        @target ||= VCAP::Micro::ConfigFile.new.api_host
      end

      def login
        @token = client.login(DEFAULT_USERNAME, DEFAULT_PASSWORD)
      rescue => e
        logger.error("Failed to login to create org and space: #{e.message}")
      end

      def create_space
        space = client.space
        space.name = SPACE_NAME
        space.organization = organization
        space.create!
        space
      rescue CFoundry::SpaceNameTaken
        logger.warn("Space '#{SPACE_NAME}' already exists")
        client.space_by_name(SPACE_NAME)
      end

      def organization
        @organization ||= client.organization_by_name(ORG_NAME) || create_org
      end

      def create_org
        org = client.organization
        org.name = ORG_NAME
        org.create!
        org
      rescue CFoundry::OrganizationNameTaken
        logger.warn("Organization '#{ORG_NAME}' already exists")
        client.organization_by_name(ORG_NAME)
      end

      def create_org_and_space
        login
        create_org
        create_space
      end
    end
  end
end