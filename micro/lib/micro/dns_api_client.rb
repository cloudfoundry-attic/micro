require 'rest-client'
require 'json'

module VCAP

  module Micro

    # Client for the Micro Cloud Foundry dynamic DNS API.
    class DnsApiClient

      def initialize(options={})
        @root_url = options[:root_url]
        @http_proxy = options[:http_proxy]
      end

      # Get a RestClient::Resource to the DNS API.
      def client
        RestClient.proxy = @http_proxy  if @http_proxy
        headers = { :content_type => 'application/json' }
        RestClient::Resource.new(@root_url, :headers => headers)
      end

      # Redeem an authentication nonce for an authentication token.
      def redeem_nonce(nonce)
        JSON.parse(client['/token'].post({ :nonce => nonce}.to_json))
      end

      # Update the DNS record for an IP address.
      def update_dns(ip, options)
        client["/clouds/#{options['cloud']}/#{options['name']}/dns"].put(
          { :address => ip }.to_json,
          { :'Auth-Token' => options['auth-token']})
      end

    end

  end

end
