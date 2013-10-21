require 'eee'

module EEE

  module TestHelper

    class Config

      def server(index = 0)
        Scenario.new Methods::Client.new, config['servers'][index]
      end

      def user(name = nil, domain)
        name = config['default_user'] if name.nil?
        domain = config['servers']

        user_config = config['users'][name]
        server_config = config['servers'][domain]
        user_config['username'] =
          "#{name.downcase}@#{server_config['domains'][domain]}"

        Entities::User[user_config]
      end

      def user_password(name = nil)
        name = config['default_user'] if name.nil?

        config['users'][name] ? config['users'][name]['password'] : nil
      end

      def config
        YAML.load_file @config
      end

      def initialize(config_filename)
        @config = config_filename
      end

    end

    def eee(config_filename)
      Config.new config_filename
    end

  end

end
