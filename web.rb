require "heroku"
require "sinatra"
require "sinatra/cli"

extend Sinatra::CLI

def heroku
  @heroku ||= Heroku::Client.new("david+smoke@heroku.com", "12345")
end

group "General Commands" do

  command "create [NAME]", "create a new application" do

    argument "NAME",   "the name to use for the application"
    option   "stack",  "the target stack for the application"
    option   "remote", "the git remote to use"

    action do
      display "creating your app..."
      execute "create app"
    end
  end

  command "destroy <NAME>", "destroy an application" do

    argument "NAME",   "the name of the application to destroy"

    action do
      display "touching your foo"
      execute "touch foo"
    end
  end

end

group "Other Group" do

  command "other:test", "do something" do

    action do
      display "creating your app..."
      execute "create app"
    end
  end

end
