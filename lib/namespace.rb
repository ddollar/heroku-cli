$:.unshift File.expand_path("../../vendor/heroku/lib")
require "heroku"

class Namespace
  attr_reader :client

  def initialize(auth)
    @client = Heroku::Client.new(auth[:username], auth[:password])
  end

private ######################################################################

  def output
    stream = StringIO.new
    yield stream
    [200, {}, stream.string]
  end

end
