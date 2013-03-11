module Borg
  module CLI
    module Applications
      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_applications, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_applications
      end

      def execute_requested_actions_with_applications(config)
        # load applications
        unless @apps_loaded
          Dir["./cap/applications/**/*.rb"].each do |file|
            config.load file
          end
          @apps_loaded = true
        end

        options[:applications] = []
        options[:actions] = Array(options[:actions]).keep_if do |action|
          app, stg = action.split(":").map(&:to_sym)
          if config.applications[app] and config.applications[app].stages[stg]
            options[:applications] << config.applications[app].stages[stg]
            false
          elsif config.applications[app] and stg.nil?
            if config.applications[app].stages.empty?
              options[:applications] << config.applications[app]
            else
              config.applications[app].stages.each{|name, stg| options[:applications] << stg}
            end
            false
          else
            true
          end
        end

        if options[:applications].empty?
          execute_requested_actions_without_applications(config)
        else
          if options[:tasks]
            puts "Will display task list for all applications"
            # I think this should not be threaded to get a clean display
            options[:applications].each do |app|
              puts "Dsplaying Task List for #{app.name}"
              execute!
            end

          elsif options[:explain]
            # I think this should not be threaded to get a clean display
            options[:applications].each do |app|
              puts "Displaying Explain Task for #{app.name}"
              execute!
            end

          else
            puts "Will execute all applications and run actions for them"
            # Executing sequentially to make sure it works but will thread this out later
            options[:applications].each do |app|
              begin
                config = instantiate_configuration(options)
                config.debug = options[:debug]
                config.dry_run = options[:dry_run]
                config.preserve_roles = options[:preserve_roles]
                config.logger.level = options[:verbose]

                set_pre_vars(config)
                load_recipes(config)
                app.load_into config

                config.trigger(:load)
                execute_requested_actions(config)
                config.trigger(:exit)

                config
              rescue Exception => error
                handle_error(error)
              end
            end
          end
        end
      end
    end
  end
end

Capistrano::CLI.send :include, Borg::CLI::Applications
