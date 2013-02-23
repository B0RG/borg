# Ensure ruby 1.9.X
raise "Ruby 1.9.X required" unless RUBY_VERSION =~ /^1\.9\.\d$/
require 'erb'
require 'yaml'

set :config_name, ARGV.first

# Load all custom libraries
Dir['./lib/**/*.rb'].each     { |  lib | require(lib) }

load 'capistrano/output'
load 'capistrano/role_reset'
load 'capistrano/helpers'

Signal.trap "SIGINT" do
  say "Exiting..."
  exit 1
end
