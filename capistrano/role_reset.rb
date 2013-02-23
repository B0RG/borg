module ::Capistrano
  class Role
    def reset!
      @dynamic_servers.each(&:reset!)
    end
  end
end
