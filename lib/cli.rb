class CLI

  def initialize(args)
    command = args.shift

    namespace, path = case command.split(':').length
      when 1 then "app", command
      else        command.split(":", 2)
    end
  end

  def execute
  end

private ######################################################################

  def parse_args(args)
    args    = []
    options = {}

    args.each do |arg|
      case arg
        when /^--(\w+)="?(.*)"?$/ then options[$1.to_sym] = $2
        when /^--(\w+)$/          then options[$1.to_sym] = true
        else                      args << arg
      end
    end

    [args, options]
  end

end
