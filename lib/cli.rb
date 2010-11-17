require "json"
require "logger"
require "rest-client"
require "pp"

class CLI

  def self.execute(args)
    path   = args.dup.shift.to_s
    params = parse_command_line(args)

    if path == "help"
      path = args[1]
      puts cli_server["/#{path.to_s.gsub(':', '/')}"].get(headers)
    else
      body = cli_server["/#{path.to_s.gsub(':', '/')};#{params[:args].join(";")}"].post(params[:options], headers)

      JSON.parse(body).each do |(command, data)|
        case command
        when "display" then
          puts data
        when "warning" then
          puts "WARNING: #{data}"
        when "error" then
          puts "ERROR: #{data}"
        when "confirm" then
          puts data
          execute(args.concat["--confirm=#{STDIN.gets.strip}"])
        when "execute" then
          puts "Executing: #{data}"
          print "Is this OK? (y/N): "
          system data if STDIN.gets.strip[0..0].upcase == "Y"
        else
          puts "unknown"
        end
      end
    end
  end

private ######################################################################

  def self.parse_command_line(command_line_args)
    args    = []
    options = {}

    command_line_args.each do |arg|
      case arg
        when /^--(\w+)="?(.*)"?$/ then options[$1.to_sym] = $2
        when /^--(\w+)$/          then options[$1.to_sym] = true
        else                      args << arg
      end
    end

    { :args => args, :options => options }
  end

  def self.headers
    {
      "X-CLI-Version"    => "heroku/2.0.0.alpha",
      "X-CLI-Executable" => "heroku"
    }
  end

  def self.cli_server
    #RestClient.log = Logger.new(STDOUT)
    @cli_server ||= RestClient::Resource.new(
      "http://localhost:9393",
      "david+smoke@heroku.com",
      "12345"
    )
  end

end
