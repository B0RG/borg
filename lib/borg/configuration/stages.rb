module Borg
  module Configuration
    module Stages
      def stage(app, name, &block)
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

        # TODO: We might want to name this differently
        def name
          "#{parent.name}:#{@name}"
        end

        def initialize(name, parent)
          @execution_blocks = []
          @name = name
          @parent = parent
        end

        def load_into(config)
          if config.respond_to?(:stage)
            # Undefine the stage method now that the app:stage config is created
            config_metaclass = class << config; self; end
            config_metaclass.send(:undef_method, 'stage')

            # Create a capistrano variable for stage
            config.instance_exec(@name, &(lambda { |name| set :stage, name }))
          end

          parent.load_into(config)
          @execution_blocks.each { |blk| config.load(&blk) }
        end
      end
    end
  end
end

Capistrano::Configuration.send(:include, Borg::Configuration::Stages)
