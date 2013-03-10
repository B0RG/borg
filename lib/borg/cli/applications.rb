module Borg
  module CLI
    module Applications
      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_applications, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_applications
      end

      def execute_requested_actions_with_applications(config)
        # load applications
        Dir["./cap/applications/**/*.rb"].each do |file|
          config.load file
        end

        options[:applications] = []
        options[:actions] = Array(options[:actions]).keep_if do |action|
          app, stg = action.split(":").map(&:to_sym)
          if config.applications[app] and config.applications[app].stages[stg]
            options[:applications] << config.applications[app].stages[stg]
            false
          elsif config.applications[app] and stg.nil?
            options[:applications] << config.applications[app]
          else
            true
          end
        end

        if options[:applications].empty?
          execute_requested_actions_without_applications(config)
        else
          if options[:tasks]
            puts "Will display task list for all applications"
            # Execute all applications and then call task_list for all of them
          elsif options[:explain]
            puts "Will display explain task for all applications"
            # Execute all applications and then call explain_task for all of them
          else
            puts "Will execute all applications and run actions for them"
            # Execute all applications and execute actions against them for all of them
          end
        end
      end
    end
  end
end

Capistrano::CLI.send :include, Borg::CLI::Applications
