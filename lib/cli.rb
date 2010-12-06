require "json"
require "logger"
require "rest-client"
require "pp"

class CLI

  class UnknownCommand < StandardError; end

  def self.run(args)
    path   = args.dup.shift.to_s
    params = parse_command_line(args[1..-1])

    if path == "help"
      path = args[1]
      puts cli_server["/#{path.to_s.gsub(':', '/')}"].get(headers)
    else
      body = cli_server["/#{path.to_s.gsub(':', '/')};#{params[:args].join(";")}"].post(params[:options], headers)

      JSON.parse(body)["commands"].each do |(command, data)|
        case command
          when "display" then display(data)
          when "warning" then warning(data)
          when "error"   then error(data)
          when "confirm" then confirm(data, args)
          when "execute" then execute(data)
          else                raise UnknownCommand
        end
      end
    end
  rescue RestClient::Unauthorized
    puts "invalid credentials"
  rescue RestClient::ResourceNotFound
    puts "invalid command"
  end

  def self.display(message)
    puts message
  end

  def self.warning(message)
    puts "WARNING: #{message}"
  end

  def self.error(message)
    puts "ERROR: #{message}"
  end

  def self.confirm(message="are you sure?", args)
    print "#{message} [y/N]: "
    run(args.concat(["--confirm=#{STDIN.gets.strip}"]))
  end

  def self.execute(command)
    puts "executing: #{command}"
    system "#{command} 2>&1"
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
      "http://localhost:5000",
      "david+smoke@heroku.com",
      "12345"
    )
  end

end
