require 'capistrano/cli'
require 'borg/cli/applications'
require 'borg/cli/assimilator'
require 'borg/configuration'
require 'borg/errors'

module Borg
  class CLI < Capistrano::CLI
    # override method in Capistrano::CLI::Execute
    def instantiate_configuration(options = {}) #:nodoc:
      Borg::Configuration.new(options)
    end

    # override method in Capistrano::CLI::Execute
    def handle_error(error) #:nodoc:
      case error
        when Net::SSH::AuthenticationFailed
          abort "authentication failed for `#{error.message}'"
        when Borg::BaseError
          abort(error.message)
        else raise error
      end
    end

    # Mix-in our own behavior
    include Applications, Assimilator
  end
end
