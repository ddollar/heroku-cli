Start the server with:

    foreman start

The Procfile contains both a server for core functionality, and a sample addon

Try commands:

    bundle exec bin/heroku help
    bundle exec bin/heroku help list
    bundle exec bun/heroku help someaddon

    bundle exec bin/heroku list
    bundle exce bin/heroku someaddon:foo

Interesting files:

    web.rb
    addon.rb

Most of the logic is here:

http://github.com/ddollar/sinatra-cli
