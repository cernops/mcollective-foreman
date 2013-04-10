require 'net/http'
require 'net/https'
require 'timeout'

module MCollective
  class Discovery
    class Foreman
      attr_reader :res

      SETTINGS = {
        :url          => Config.instance.pluginconf["foreman.url"]
        :puppetdir    => '/var/lib/puppet',
        :facts        => true,
        :timeout      => 7,
        :storeconfigs => false,
        # if CA is specified, remote Foreman host will be verified 
        :ssl_ca       => "/var/lib/puppet/ssl/certs/ca.pem",
        # ssl_cert and key are required if require_ssl_puppetmasters is enabled in Foreman 
        :ssl_cert     => Config.instance.pluginconf["foreman.ssl_cert"] || "",
        :ssl_key      => Config.instance.pluginconf["foreman.ssl_key"] || ""
      }

      def self.discover(filter, timeout, limit=0, client=nil)
        options = client.options[:discovery_options].first
        get(options).flatten
      end

      private

      def self.get(options)
        uri = URI.parse(URI.escape("#{SETTINGS[:url]}/api/hosts?search=#{options}&per_page=9999999"))
        req = Net::HTTP::Get.new(uri.request_uri)
        credentials = authenticate_user
        req.basic_auth credentials[:login], credentials[:password]
        @res = Net::HTTP.new(uri.host, uri.port)
        @res.use_ssl = uri.scheme == 'https'
        setup_ssl_certs if @res.use_ssl?
        begin
          timeout(SETTINGS[:timeout]) do
            response = @res.start { |http| http.request(req) }
            handle_response response
          end
        rescue TimeoutError, SocketError, Errno::EHOST
          puts "Request timed out"
        end

      end

      def self.handle_response(response)
        case response.code.to_i
        when 200
          JSON.parse(response.body).map { |host| host['host']['name'] }
        when 401
          puts "Username/password are wrong" 
          exit(1)
        when 403
          puts "Bad request"
          exit(1)
        end                             
      end

      def self.authenticate_user
        fd = IO.sysopen "/dev/tty", "w"
        ios = IO.new(fd, "w")
        ios.puts "Username: "
        username = gets.chomp
        ios.puts "Password: "
        system `stty -echo`
        password = gets.chomp
        system `stty echo`
        ios.close

        { :login => username, :password => password }
      end

      def self.setup_ssl_certs
        if SETTINGS[:ssl_ca]
          @res.ca_file = SETTINGS[:ssl_ca]
          @res.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          @res.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        if File.exists?(SETTINGS[:ssl_cert]) && File.exists?(SETTINGS[:ssl_key])
          @res.cert = OpenSSL::X509::Certificate.new(File.read(SETTINGS[:ssl_cert]))
          @res.key  = OpenSSL::PKey::RSA.new(File.read(SETTINGS[:ssl_key]), nil)
        end
      end
    end
  end
end

