module VCAP

  module Micro

    # An internet domain name.
    class Domain

      attr_reader :domain

      def initialize(domain)
        @domain = domain
      end

      # The rules are a little looser than real domain names because fake
      # domain like 'test.micro' are allowed.
      def valid?
        /^[a-z\d](?:[a-z\d-]{1,61}[a-z\d])?\.[a-z\d](?:[a-z\d-]{0,61}[a-z\d])$/i.match(@domain) ? true : false
      end

    end

  end

end
