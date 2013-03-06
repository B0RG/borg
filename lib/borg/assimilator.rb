module Borg
  module Assimilator
    def assimilate gem_name
      gem_home = Gem::Specification.find_by_name(gem_name).gem_dir
      Capistrano::Configuration.instance.load do
        Dir["#{gem_home}/collective/initializers/**/*.rb"].each do |file|
          load file
        end
        @load_paths << "#{gem_home}/collective"
      end
    end
  end
end
