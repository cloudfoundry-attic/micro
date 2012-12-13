ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile", __FILE__)
require 'rubygems'
require 'bundler'
Bundler.require(:default, :console)

require 'micro/console'
VCAP::Micro::Console.run