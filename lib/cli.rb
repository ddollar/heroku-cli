require "json"
require "logger"
require "rest-client"
require "pp"
require "term/ansicolor"

class CLI

  extend Term::ANSIColor

  class UnknownCommand < StandardError; end

  def self.run(args, server=nil)
    path   = args.dup.shift.to_s
    params = parse_command_line(args[1..-1])
    server = cli_server(server)

    if path == "help"
      path = args[1]
      #print_header
      puts server[build_path(path)].get(headers)
    else
      body = server[build_path(path, params[:args])].post(params[:options], headers)
      #print_header
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
  rescue RestClient::Found => ex
    run(args, ex.response.headers[:location])
  rescue RestClient::Unauthorized
    puts "invalid credentials"
  rescue RestClient::ResourceNotFound
    puts "invalid command"
  end

  def self.build_path(path, args=[])
    [ path.to_s.gsub(":", "/") ].concat(args).join(";")
  end

  def self.display(message)
    puts message
  end

  def self.warning(message)
    puts "WARNING: #{message}"
  end

  def self.error(message)
    puts red { message }
  end

  def self.confirm(message="are you sure?", args={})
    print "#{message} [y/N]: "
    run(args.concat(["--confirm=#{STDIN.gets.strip}"]))
  end

  def self.execute(command)
    puts red { "\n#{command}" }
    output = %x{ #{command} 2>&1 }
    print black { bold { format_execute_output(output) } }
  end

  private ######################################################################

  def self.username
    "david+smoke@heroku.com"
  end

  def self.print_header
    print magenta { bold { "Heroku" } }
    puts  magenta + " [" + black + bold + username + reset + magenta + "]" + reset
    puts
  end

  def self.format_execute_output(output)
    "  " + output.gsub("\n", "\n  ")
  end

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

  def self.cli_server(server=nil)
    server ||= "http://localhost:5000"

    #RestClient.log = Logger.new(STDOUT)
    RestClient::Resource.new(
      server,
      username,
      "12345"
    )
  end

end
