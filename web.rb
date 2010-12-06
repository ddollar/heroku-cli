require "crack"
require "heroku"
require "logger"
require "sinatra"
require "sinatra/cli"

disable :logging

extend Sinatra::CLI

before do |request|
  auth = Rack::Auth::Basic::Request.new(request.env)
  if auth.provided? && auth.basic? && auth.credentials
    heroku = Heroku::Client.new(auth.credentials.first, auth.credentials.last)
    request.env['cli.username'] = auth.credentials.first
    request.env['cli.heroku']   = heroku
  else
    unauthorized(response)
  end
end

error_handler RestClient::UnprocessableEntity do
  begin
    parsed = Crack::XML.parse(exception.response.to_s)
    error  parsed["errors"]["error"]
  rescue
    parsed = Crack::JSON.parse(exception.response.to_s)
    error  parsed.inspect
  end
end

error_handler RestClient::Unauthorized do
  unauthorized(response)
end

def unauthorized(response)
  response['WWW-Authenticate'] = %{Basic realm="HTTP Auth"}
  throw(:halt, [401, "Not Authorized\n"])
end

def heroku
  request.env['cli.heroku']
end

def username
  request.env['cli.username']
end

group "General Commands" do

  command "create [NAME]", "create a new application" do
    argument "NAME",   "the name to use for the application"
    option   "stack",  "the target stack for the application"
    option   "remote", "the git remote to use"

    action do
      app = heroku.create(args.first, options)
      display "created application: #{app}"
      display "  url: http://#{app}.heroku.com/"
      display "  git: git@heroku.com:#{app}.git"
    end
  end

  command "destroy <NAME>", "destroy an application" do
    argument "NAME",   "the name of the application to destroy"

    action do
      app = args.first
      error "must specify an app name to delete" unless app
      confirm "are you sure you want to delete #{app}?" do
        begin
          heroku.destroy(app)
          display "deleted #{app}"
        rescue RestClient::ResourceNotFound
          error "no such app: #{app}"
        end
      end
    end
  end

  command "list", "list applications" do
    action do
      heroku.list.each do |app, owner|
        display "%-40s %s" % [app, (owner == username) ? "" : owner]
      end
    end
  end

end

group "Other Group" do

  command "other:test", "do something" do
    action do
      display "executing"
    end
  end

end

group "External Addons" do
  redirect "someaddon", "Some Addon", "http://localhost:5100"
end

