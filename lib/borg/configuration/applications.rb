module Borg
  module Configuration
    module Applications

      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_applications, :initialize
        base.send :alias_method, :initialize, :initialize_with_applications
      end
      attr_reader :applications

      def initialize_with_applications(*args) #:nodoc:
        initialize_without_applications(*args)
        @applications = {}
      end
      private :initialize_with_applications

      def application (name, &block)
        name = name.to_sym
        namespace name do
          desc "Load Application #{name} (All Stages if any)"
          task :default do
            @applications[name].execute
          end
        end
        @applications[name] ||= Application.new(name, @namespaces[name])
        @applications[name].execution_blocks << block if block_given?
      end

      class Application
        attr_accessor :execution_blocks
        attr_accessor :stages
        attr_reader   :name

        def initialize name, namespace
          @execution_blocks = []
          @name = name
          @namespace = namespace
          @stages = {}
        end

        def load_into config
          if config.respond_to?(:application)
            # Undefine the stage method now that the app:stage config is created
            config_metaclass = class << config; self; end
            config_metaclass.send(:undef_method, 'application')

            # Create a capistrano variable for stage
            config.instance_exec(@name, &(lambda { |name| set :application, name }))
          end
          @execution_blocks.each {|blk| config.load &blk}
        end
      end
    end
  end
end

Capistrano::Configuration.send :include, Borg::Configuration::Applications
