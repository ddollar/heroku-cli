require "crack"
require "heroku"
require "logger"
require "sinatra"
require "sinatra/cli"

disable :logging

extend Sinatra::CLI

group "Test Addon" do

  command "someaddon:foo [ARG]", "foo the addon" do
    argument "ARG",    "the argument"
    option   "test",   "test option"
    option   "test2",  "another test option"

    action do
      display "fooing the addon"
    end
  end

end
