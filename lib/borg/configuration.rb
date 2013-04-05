require 'capistrano/configuration'
require 'borg/configuration/applications'
require 'borg/configuration/assimilator'
require 'borg/configuration/stages'

# TODO This is major ugliness here...
module Capistrano
  class Configuration
    module Namespaces
      def filter_task(name, options={}, &block)
        puts "________________)____"
        task(name, options) do
          filter_hosts find_servers_for_task(current_task).join(','), &block
        end
      end

      def filter_hosts(hosts, &block)
        original_hostfilter = ENV['HOSTFILTER']
        ENV['HOSTFILTER'] = hosts
        logger.info "changing HOSTFILTER from #{original_hostfilter} to #{hosts}".cyan
        block.call
        logger.info "resetting HOSTFILTER to #{original_hostfilter}".cyan
        ENV['HOSTFILTER'] = original_hostfilter
      end

      def remote_condition(bash_cmd)
        run bash_cmd
        true
      rescue
        false
      end

      def hosts_failing_remote_condition(bash_cmd)
        failing_hosts = []
        begin
          run bash_cmd
        rescue NoMethodError => e
          raise e
        rescue Exception => e
          failing_hosts = e.hosts
        end
        failing_hosts
      end

      def on_hosts_passing_remote_condition(bash_cmd, &block)
        failing_hosts = hosts_failing_remote_condition bash_cmd
        filter_hosts find_servers_for_task(current_task).reject{|h| failing_hosts.include?(h)}.join(','), &block
      end

      def on_hosts_failing_remote_condition(bash_cmd, &block)
        failing_hosts = hosts_failing_remote_condition bash_cmd
        filter_hosts failing_hosts.join(','), &block
      end
    end
  end
end

module Borg
  class Configuration < Capistrano::Configuration
    # Mix-in our own behavior
    include Applications, Assimilator, Stages

    # source: capistrano/recipes/deploy.rb
    def _cset(name, *args, &block)
      set(name, *args, &block) unless exists?(name)
    end

  end
end
