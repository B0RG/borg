module Borg
  module CLI
    module Assimilator
      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_assimilator, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_assimilator
      end

      def execute_requested_actions_with_assimilator(config)
        config.assimilate!
        execute_requested_actions_without_assimilator config
      end
    end
  end
end

Capistrano::CLI.send :include, Borg::CLI::Assimilator
