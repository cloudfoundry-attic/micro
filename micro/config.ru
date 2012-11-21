$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

# TODO: remove this
$:.unshift '/var/vcap/bosh/agent/lib'

require 'rack/rewrite'

require 'micro'

use VCAP::Micro::Api::Engine::Rack::MediaTypeSerial

use Rack::Rewrite do
  rewrite '/', '/index.html'
end

use Rack::Static, :urls => %w{/index.html /assets}, :root => 'public'

map '/api' do
  run VCAP::Micro::Api::Server
end
