require 'capistrano'
require 'erb'

require 'borg/assimilator'
require 'borg/errors'
require 'borg/server/base'

# Ensure ruby 1.9.X
raise "Ruby 1.9.X required" unless RUBY_VERSION =~ /^1\.9\.\d$/

# source capistrano/deploy.rb
def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

Capistrano::Configuration.send :include, Borg::Assimilator
Capistrano::Configuration.instance.load do
  assimilate "borg"

end unless Capistrano::Configuration.instance.nil?
