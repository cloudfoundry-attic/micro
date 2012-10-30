$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

# TODO: remove this
$:.unshift '/var/vcap/bosh/agent/lib'

require 'micro'

use VCAP::Micro::Api::Engine::Rack::MediaTypeSerial

map '/api' do
  run VCAP::Micro::Api::Server
end
