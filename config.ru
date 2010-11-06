require "rubygems"
require "bundler/setup"

$:.unshift File.expand_path("../lib", __FILE__)

$:.unshift File.dirname(__FILE__)
require "web"

run Sinatra::Application
