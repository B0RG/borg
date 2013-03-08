_cset :borg_sigint_triggers_exit, true

if borg_sigint_triggers_exit
  __cap = Capistrano::Configuration.instance
  ::Signal.trap "SIGINT" do
    __cap.trigger :exit
    exit 1
  end
end
