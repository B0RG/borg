# Added for convenience allowing dynamic

module ::Capistrano
  class Role
    def reset!
      @dynamic_servers.each(&:reset!)
    end
  end
end

desc 'Resets all dynamic capistrano roles.'
task(:reset_roles) { roles.each {|k,v| v.reset!} }
