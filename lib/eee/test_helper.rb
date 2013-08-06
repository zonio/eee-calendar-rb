require 'eee'

module EEE

  module TestHelper

    class Config

      def server(index = 0)
        Scenario.new Methods::Client.new, config['servers'][index]
      end

      def user(name = nil, domain = 0, server = 0)
        name = config['default_user'] if name.nil?

        user_config = config['users'][name]
        server_config = config['servers'][server]
        user_config['username'] =
          "#{name.downcase}@#{server_config['domains'][domain]}"

        Entities::User[user_config]
      end

      def user_password(name = nil)
        name = config['default_user'] if name.nil?

        config['users'][name]['password']
      end

      def users(domain = 0, server = 0)
        server_config = config['servers'][server]
        config['users'].map do |user|
          "#{user.first.downcase}@#{server_config['domains'][domain]}"
        end
      end

      def calendars
        config['calendars']
      end

      private

      def config
        YAML.load_file @config
      end

      public

      def initialize(config_filename)
        @config = config_filename
      end

    end

    def eee(config_filename)
      Config.new config_filename
    end

  end

end
