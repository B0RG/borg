# source capistrano/deploy.rb
Capistrano::Configuration.instance(:must_exist).load do
  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  assimilate "borg-rb"
end
