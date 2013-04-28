require 'date'
require 'ri_cal'
require 'eee/entities'

module EEE

  module Methods

    class Call

      attr_reader :name
      attr_reader :xmlrpc_params
      attr_reader :result

      def params=(params)
        @xmlrpc_params = []
        param_defs_enum = @param_defs.each
        params_enum = params.each

        loop do
          param = params_enum.next
          param_def = param_defs_enum.next
          if param_def[:type].respond_to?(:first) and
              Entities::Base > param_def[:type].first
            @xmlrpc_params << param.map(:id).join(':')
          elsif Entities::Base > param_def[:type]
            @xmlrpc_params << param.id
          elsif Entities::Attribute >= param_def[:type]
            @xmlrpc_params << param.name
            @xmlrpc_params << param.value
            @xmlrpc_params << param.is_public
          elsif RiCal::Component >= param_def[:type]
            @xmlrpc_params << param.export
          else
            @xmlrpc_params << param
          end
        end

        loop do
          @xmlrpc_params << param_defs_enum.next[:default]
        end
      end

      def xmlrpc_result=(xmlrpc_result)
        if @result_def and @result_def[:type] and
            @result_def[:type].respond_to?(:first) and
            (Entities::Base > @result_def[:type].first or
             Entities::Attribute >= @result_def[:type].first)
          @result = xmlrpc_result.map { |data| @result_def[:type].first[data] }
        elsif @result_def and @result_def[:type] and
            (Entities::Base > @result_def[:type] or
             Entities::Attribute >= @result_def[:type])
          @result = @result_def[:type][xmlrpc_result]
        elsif @result_def and @result_def[:type] and
            RiCal::Component >= @result_def[:type]
          @result = RiCal.parse_string xmlrpc_result
        else
          @result = xmlrpc_result
        end
      end

      def initialize(name, param_defs, result_def)
        @name = name
        @param_defs = param_defs
        @result_def = result_def
        @xmlrpc_params = []
      end

    end

    module Definition

      class Options
        attr_reader :param_defs
        attr_reader :result_def

        def in(type, default = nil)
          @param_defs << {
            type: type,
            default: default
          }
        end

        def out(type)
          @result_def = { type: type }
        end

        def initialize
          @param_defs = []
          @result_def = nil
        end
      end

      module ClassMethods

        def eee_method(ruby_name)
          options = Options.new
          yield options if block_given?

          define_method ruby_name do |params = nil|
            eee_method_call = Call.new(
              Definition::eee_method_xmlrpc_name(self.class.name, ruby_name),
              options.param_defs,
              options.result_def
            )
            eee_method_call.params = params if params

            eee_method_call
          end
        end

      end

      def self.included(eee_definition_class)
        eee_definition_class.extend ClassMethods
      end

      def self.eee_method_xmlrpc_name(class_name, ruby_name)
        'ES' + class_name.split('::').last + '.' + ruby_name.to_s.split('_')
          .map.with_index do |word, idx|
            if idx > 0
              word.capitalize
            else
              word
            end
          end
          .join('')
      end

    end

    class Client
      include Definition

      eee_method :get_server_attributes do |m|
        m.in String, ''
        m.out [Entities::Attribute]
      end

      eee_method :authenticate do |m|
        m.in Entities::User
        m.in String
        m.out TrueClass
      end

      eee_method :sudo do |m|
        m.in Entities::User
        m.out TrueClass
      end

      eee_method :create_calendar do |m|
        m.in Entities::Calendar
        m.out TrueClass
      end

      eee_method :delete_calendar do |m|
        m.in Entities::Calendar
        m.out TrueClass
      end

      eee_method :get_calendars do |m|
        m.in String, ''
        m.out [Entities::Calendar]
      end

      eee_method :get_shared_calendars do |m|
        m.in String, ''
        m.out [Entities::Calendar]
      end

      eee_method :set_calendar_attribute do |m|
        m.in [Entities::User, Entities::Calendar]
        m.in Entities::Attribute
        m.out TrueClass
      end

      eee_method :set_user_permission do |m|
        m.in Entities::Calendar
        m.in Entities::User
        m.in Entities::UserPermission
        m.out TrueClass
      end

      eee_method :get_user_permissions do |m|
        m.in Entities::Calendar
        m.out Entities::UserPermission
      end

      eee_method :set_group_permission do |m|
        m.in Entities::Calendar
        m.in Entities::Group
        m.in Entities::GroupPermission
        m.out TrueClass
      end

      eee_method :get_group_permissions do |m|
        m.in Entities::Calendar
        m.out Entities::GroupPermission
      end

      eee_method :subscribe_calendar do |m|
        m.in [Entities::User, Entities::Calendar]
        m.out TrueClass
      end

      eee_method :unsubscribe_calendar do |m|
        m.in [Entities::User, Entities::Calendar]
        m.out TrueClass
      end

      eee_method :add_object do |m|
        m.in [Entities::User, Entities::Calendar]
        m.in RiCal::Component
        m.out TrueClass
      end

      eee_method :update_object do |m|
        m.in [Entities::User, Entities::Calendar]
        m.in RiCal::Component
        m.out TrueClass
      end

      eee_method :delete_object do |m|
        m.in [Entities::User, Entities::Calendar]
        m.in String
        m.out TrueClass
      end

      eee_method :query_objects do |m|
        m.in [Entities::User, Entities::Calendar]
        m.in String, ''
        m.out RiCal::Component::Calendar
      end

      eee_method :free_busy do |m|
        m.in Entities::User
        m.in DateTime
        m.in DateTime
        m.in RiCal::Component::Timezone
        m.out RiCal::Component::Freebusy
      end

      eee_method :create_user do |m|
        m.in Entities::User
        m.in String
        m.out TrueClass
      end

      eee_method :delete_user do |m|
        m.in Entities::User
        m.out TrueClass
      end

      eee_method :get_users do |m|
        m.in String, ''
        m.out [Entities::User]
      end

      eee_method :change_password do |m|
        m.in String
        m.out TrueClass
      end

      eee_method :set_user_attribute do |m|
        m.in Entities::Attribute
        m.out TrueClass
      end

      eee_method :get_user_attributes do |m|
        m.in String, ''
        m.out [Entities::Attribute]
      end

      eee_method :create_alias do |m|
        m.in Entities::Alias
        m.out TrueClass
      end

      eee_method :delete_alias do |m|
        m.in Entities::Alias
        m.out TrueClass
      end

      eee_method :get_aliases do |m|
        m.out [Entities::Alias]
      end

      eee_method :create_domain_alias do |m|
        m.in Entities::Alias
        m.out TrueClass
      end

      eee_method :delete_domain_alias do |m|
        m.in Entities::Alias
        m.out TrueClass
      end

      eee_method :get_domain_aliases do |m|
        m.out [Entities::Alias]
      end

      eee_method :create_group do |m|
        m.in Entities::Group
        m.in String
        m.out TrueClass
      end

      eee_method :delete_group do |m|
        m.in Entities::Group
        m.out TrueClass
      end

      eee_method :rename_group do |m|
        m.in Entities::Group
        m.in String
        m.out TrueClass
      end

      eee_method :get_groups do |m|
        m.in String, ''
        m.out [Entities::Group]
      end

      eee_method :add_user_to_group do |m|
        m.in Entities::Group
        m.out TrueClass
      end

      eee_method :remove_user_from_group do |m|
        m.in Entities::Group
        m.out TrueClass
      end

      eee_method :get_users_of_group do |m|
        m.in Entities::Group
        m.out [Entities::User]
      end

      eee_method :get_groups_of_user do |m|
        m.out [Entities::Group]
      end

    end

    class Server
      include Definition

      eee_method :free_busy do |m|
        m.in Entities::User
        m.in DateTime
        m.in DateTime
        m.in RiCal::Component::Timezone
        m.out RiCal::Component::Freebusy
      end

      eee_method :deliver_object do |m|
        m.in String # TODO there's no iTIP implementation for Ruby to
                    # our knowledge
        m.out TrueClass
      end

    end

  end

end
