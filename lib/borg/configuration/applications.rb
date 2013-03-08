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
          task :default do
            @applications[name].execute
          end
        end
        @applications[name] = Application.new(name, @namespaces[name], &block)
      end

      class Application
        attr_accessor :execution_block
        attr_accessor :stages

        def initialize name, namespace, &block
          @name = name
          @namespace = namespace
          @execution_block = block
          @stages = {}
        end

        def execute
          stages.each{|n,s| s.execute}
        end
      end
    end
  end
end
