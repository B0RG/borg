module Borg
  module Configuration
    module Stages

      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_stages, :initialize
        base.send :alias_method, :initialize, :initialize_with_stages
      end
      attr_reader :stagess

      def initialize_with_stages(*args) #:nodoc:
        initialize_without_stages(*args)
        @stages = {}
      end
      private :initialize_with_stages

      def stage (app, name, &block)
        app = app.to_sym
        name = name.to_sym
        application app unless @applications[app]

        namespace app do
          desc "Load Application #{app} and Stage #{name}"
          task name do
            @applications[app].stages[name].execute
          end
        end
        @applications[app].stages[name] ||= Stage.new(name, @applications[app])
        @applications[app].stages[name].execution_blocks << block
      end

      class Stage
        attr_accessor :execution_blocks
        attr_accessor :parent

        def initialize name, parent, &block
          @execution_blocks = []
          @name = name
          @parent = parent
        end

        def execute
          # build new capistrano object here
          # possibly implemented as a thread so that it does not interferer with current capistrano instance
          # IMPORTANT: The capistrano config should load the block
        end
      end
    end
  end
end

Capistrano::Configuration.send :include, Borg::Configuration::Stages
