$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

# TODO: remove this
$:.unshift '/var/vcap/bosh/agent/lib'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../Gemfile", __FILE__)
require 'rubygems'
require 'bundler'
Bundler.require(:default, :web)

require 'fileutils'
require 'micro'

LOG_FILE = '/var/vcap/sys/log/micro/api.log'.freeze
FileUtils.mkdir_p File.dirname(LOG_FILE)
logger = File.new(LOG_FILE, 'a+')

use VCAP::Micro::Api::Engine::Rack::Logger, logger
use VCAP::Micro::Api::Engine::Rack::MediaTypeSerial
use Rack::CommonLogger, logger
use(Rack::Rewrite) { rewrite '/', '/index.html' }
use Rack::Static, urls: %w{/index.html /tos.html /assets}, root: 'public'

map '/api' do
  run VCAP::Micro::Api::Server
end
