require "rest-client"
require "sinatra/base"

module Sinatra
  module CLI
    def namespaces
      @@namespaces ||= {}
    end

    def register_namespace(namespace, target)
      namespaces[namespace.to_sym] = target
    end

    def execute_namespace(request, namespace, path, params={})
      auth = request.env['cli.auth']

      case target = namespaces[namespace.to_sym]
        when NilClass then raise "no such namespace"
        when String   then execute_namespace_url(target, path, auth, params)
        when Class    then execute_namespace_class(target, path, auth, params)
        else          raise "wtf"
      end
    end

protected ####################################################################

    def execute_namespace_class(target, path, auth, params)
      target.new(auth).send(path.gsub("/", "_"), params[:args], params[:options])
    # rescue NoMethodError
    #   raise "no such command"
    # rescue ArgumentError
    #   raise "malformed command"
    end

    def execute_namespace_url(target, path, auth, params)
      resource = RestClient::Resource.new(target)
      resource[path].post(params)
    end
  end

  register CLI
end
