module Borg
  module Configuration
    module Assimilator
      def assimilate gem_name
        @to_assimilate ||= {}
        @to_assimilate[gem_name] = Gem::Specification.find_by_name(gem_name).gem_dir
      end

      def assimilate!
        @to_assimilate ||= {}
        @to_assimilate.each do |gem_name, gem_home|
          Dir["#{gem_home}/cap/initializers/**/*.rb"].each do |file|
            load file
          end
          @load_paths << "#{gem_home}/cap"
        end
      end
    end
  end
end
Capistrano::Configuration.send :include, Borg::Configuration::Assimilator
