module Borg
  module Assimilator
    def assimilate gem_name
      gem_home = Gem::Specification.find_by_name(gem_name).gem_dir
      Dir["#{gem_home}/cap/initializers/**/*.rb"].each do |file|
        load file
      end
      @load_paths << "#{gem_home}/cap"
    end
  end
end
Capistrano::Configuration.send :include, Borg::Assimilator
