if fetch(:borg_sigint_triggers_exit, true)
  __cap = Capistrano::Configuration.instance
  ::Signal.trap 'SIGINT' do
    __cap.trigger :exit
    exit 1
  end
end
