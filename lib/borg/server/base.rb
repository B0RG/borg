module Borg
  module Server
    class Base < ::Capistrano::ServerDefinition

      def self.create opts
        unimplemented "Use a subclass of Borg::Server::Base that implements the create functionality."
      end

      def start
        unimplemented "Use a subclass of Borg::Server::Base that implements the start functionality."
      end

      def stop
        unimplemented "Use a subclass of Borg::Server::Base that implements the stop functionality."
      end

      def destroy
        unimplemented "Use a subclass of Borg::Server::Base that implements the destroy functionality."
      end

      private

      def unimplemented msg
        raise Borg::UnimplementedError.new msg
      end

    end
  end
end