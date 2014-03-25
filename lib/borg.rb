# Ensure ruby 1.9.X
raise 'Ruby 1.9.x, 2.x.x,  required' unless RUBY_VERSION =~ /^1\.9\.\d$/ || RUBY_VERSION =~ /^2\.\d\.\d$/

# Colors
require 'capistrano_colors'
require 'colored'
require 'term/ansicolor'

require 'borg/cli'
require 'borg/configuration'
require 'borg/errors'
require 'borg/server/base'
require 'borg/servers/base'

require 'erb'
