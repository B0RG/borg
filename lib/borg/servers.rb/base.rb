module Borg
  module Servers
    class Base
      class << self
        def all
          unimplemented "Use a subclass of Borg::Servers::Base that implements the all functionality."
        end

        def [] name
          all.select{|s| s.name == name}.first
        end

        private

        def unimplemented msg
          raise Borg::UnimplementedError.new msg
        end
      end
    end
  end
end
