require 'capistrano/configuration'
require 'borg/configuration/applications'
require 'borg/configuration/assimilator'
require 'borg/configuration/stages'

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
