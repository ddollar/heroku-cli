require "crack"
require "heroku"
require "logger"
require "sinatra"
require "sinatra/cli"

disable :logging

extend Sinatra::CLI

group "Test Addon", :prefix => "someaddon" do

  command "foo [ARG]", "foo the addon" do
    option   "test2",  "another test option"

    action do
      display "fooing the addon"
    end
  end

end
