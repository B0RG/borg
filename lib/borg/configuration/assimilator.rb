module Borg
  class Configuration < Capistrano::Configuration
    module Assimilator
      def assimilate(borg_plugin, plugin_path = nil)
        @to_assimilate ||= {}
        @to_assimilate[borg_plugin] = plugin_path || Gem::Specification.find_by_name(borg_plugin).gem_dir
      end

      def assimilate!
        @to_assimilate ||= {}
        @to_assimilate.each do |borg_plugin, plugin_path|
          Dir["#{plugin_path}/cap/initializers/**/*.rb"].each do |file|
            load file
          end
          @load_paths << "#{plugin_path}/cap"
        end
      end
    end
  end
end
