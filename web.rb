require "sinatra"
require "sinatra/cli"

extend Sinatra::CLI

Dir[File.expand_path("../lib/namespace/*.rb", __FILE__)].each do |namespace|
  require namespace
end

register_namespace :app, Namespace::App

post "/command/:namespace/*" do
  request.env['cli.auth'] = { :username => "david+smoke@heroku.com", :password => "12345" }

  status, headers, body = execute_namespace(
    request,
    params[:namespace],
    params[:splat].first,
    params[:params]
  )

  puts "STATUS:#{status} HEADERS:#{headers.inspect} BODY:#{body}"

  halt status, headers, body
end
