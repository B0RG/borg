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

      def stages (application, name, &block)
        application = application.to_sym
        name = name.to_sym
        raise ArgumentError, "application does not exist" unless @applications[application]

        namespace application do
          task name do
            @applications[name].stages[name].execute
          end
        end
        @applications[application].stages[name] = Stage.new(name, @applications[application], &block)
      end

      class Stage
        attr_accessor :execution_block
        attr_accessor :parent

        def initialize name, parent, &block
          @name = name
          @parent = parent
          @execution_block = block
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
