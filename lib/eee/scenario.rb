require 'net/http'
require 'openssl'
require 'xmlrpc/marshal'

module EEE

  class Scenario

    def append_call(method_name, *params, &block)
      @queue << {
        call: @interface.send(method_name, params),
        block: block
      }

      self
    end

    def send(uri = nil, http = nil)
      uri ||= default_uri
      http ||= default_http uri
      ok = true
      param = nil

      @queue.each do |call|
        request = Net::HTTP::Post.new uri.path
        request['Content-Type'] = 'text/xml'
        request.body = XMLRPC::Marshal.dump_call(call[:call].name,
                                                 *call[:call].xmlrpc_params)

        response = http.request request
        unless response.code == '200' and
            response['Content-Type'] =~ /^text\/xml(;.+)?$/
          ok = false
          param = nil
          break
        end

        call[:call].xmlrpc_result = XMLRPC::Marshal.load_response response.body
        param = call[:call].result

        call[:block].call param if call[:block]
      end

      http.finish

      @queue = []
      [ok, param]
    end

    def initialize(interface, defaults = {})
      @interface = interface
      @defaults = defaults
      @queue = []
    end

    private

    def default_host
      @defaults['host'] || 'localhost'
    end

    def default_port
      @defaults['port'] || 4444
    end

    def default_uri
      URI "https://#{default_host}:#{default_port}/RPC2"
    end

    def default_http(uri)
      Net::HTTP.start uri.host, uri.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
    end

  end

end
