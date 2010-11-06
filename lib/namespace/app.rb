require "namespace"

class Namespace::App < Namespace

  def list(args=[], options={})
    output do |stream|
      client.list.sort_by(&:first).each do |(app, owner)|
        display_owner = owner == client.user ? '' : owner
        stream.puts "%-30s %s" % [app, display_owner]
      end
    end
  end

end
