# source capistrano/deploy.rb
def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

assimilate "borg"
