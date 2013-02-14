module VCAP
  module Micro
    class Settings

      def self.preserve(properties, service, key)
        properties[service] && properties[service][key]
      end

      def self.secret(n)
        OpenSSL::Random.random_bytes(n).unpack("H*")[0]
      end

      def self.randomize_password(properties, service, key, len)
        properties[service] = {} unless properties[service]
        unless preserve(properties, service, key)
          properties[service][key] = secret(len)
        end
      end

      # TODO: template settings file
      def self.randomize_passwords(properties)
        randomize_password(properties, 'cc', 'token', 64)
        randomize_password(properties, 'cc', 'password', 64)
        randomize_password(properties, 'cc', 'staging_upload_user', 8)
        randomize_password(properties, 'cc', 'staging_upload_password', 9)
        randomize_password(properties, 'ccng', 'bulk_api_password', 64)
        randomize_password(properties, 'ccng', 'staging_upload_user', 8)
        randomize_password(properties, 'ccng', 'staging_upload_password', 9)
        randomize_password(properties, 'router', 'password', 8)
        router = properties['router']
        randomize_password(router, 'status', 'user', 8)
        randomize_password(router, 'status', 'password', 8)
        randomize_password(properties, 'nats', 'password', 8)

        ccdb_password = secret(8)
        properties['ccdb']['roles'].find {
          |role| role['tag'] == 'admin' }['password'] = ccdb_password
        properties['ccdb_ng']['roles'].find {
          |role| role['tag'] == 'admin' }['password'] = ccdb_password

        uaadb_password = secret(8)
        properties['ccdb']['roles'].find {
          |role| role['tag'] == 'uaa' }['password'] = uaadb_password
        properties['ccdb_ng']['roles'].find {
          |role| role['tag'] == 'uaa' }['password'] = uaadb_password
        properties['uaadb']['roles'].find {
          |role| role['tag'] == 'admin' }['password'] = uaadb_password

        randomize_password(properties, 'mysql_node', 'password', 8)
        randomize_password(properties, 'mysql_gateway', 'token', 4)
        randomize_password(properties, 'redis_gateway', 'token', 4)
        randomize_password(properties, 'mongodb_gateway', 'token', 4)

        randomize_password(properties, 'postgresql_gateway', 'admin_passwd_hash', 4)
        randomize_password(properties, 'postgresql_gateway', 'token', 8)

        properties['postgresql_node'] = {} unless properties['postgresql_node']
        properties['postgresql_node']['admin_passwd_hash'] = properties['postgresql_gateway']['admin_passwd_hash']

        randomize_password(properties, 'rabbit_gateway', 'token', 64)

        randomize_password(properties, 'serialization_data_server',
          'upload_token', 32)

        vcap_redis_password = secret(24)
        properties['service_lifecycle']['resque']['password'] = \
          vcap_redis_password
        properties['vcap_redis']['password'] = vcap_redis_password

        randomize_password(properties['uaa'], 'cc', 'token_secret', 32)
        randomize_password(properties['uaa'], 'cc', 'client_secret', 32)
        randomize_password(properties['uaa'], 'admin', 'client_secret', 24)
        randomize_password(properties['uaa'], 'batch', 'username', 13)
        randomize_password(properties['uaa'], 'batch', 'password', 13)

        properties
      end

    end
  end
end
