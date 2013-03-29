module Borg
  class CLI < Capistrano::CLI
    module Applications
      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_applications, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_applications
      end

      # TODO: documentation for `options`, where does it come from?
      def execute_requested_actions_with_applications(config)
        load_applications(config)
        separate_actions_and_applications(config)
        if options[:applications].empty? or Thread.current[:borg_application]
          Thread.current[:borg_application].load_into config if Thread.current[:borg_application]
          execute_requested_actions_without_applications(config)
        else
          options[:applications].each do |app|
            puts "Executing commands in context of #{app.name}"
            Thread.current[:borg_application] = app
            execute!
          end
        end
      end

      private

      def load_applications(config)
        unless @apps_loaded
          Dir["./cap/applications/**/*.rb"].each { |file| config.load(file) }
          @apps_loaded = true
        end
      end

      def separate_actions_and_applications(config)
        options[:applications] = []
        found_non_application = false
        options[:actions] = Array(options[:actions]).keep_if do |action|
          app, stg = action.split(":").map(&:to_sym)
          ret = if config.applications[app] and config.applications[app].stages[stg]
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
            found_non_application = true
            true
          end
          raise ArgumentError, "Can not have non application configs between application configs" if !ret and found_non_application
          ret
        end
      end
    end
  end
end
