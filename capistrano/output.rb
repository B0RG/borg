# Colors 
require 'colored'
require 'term/ansicolor'
require 'capistrano_colors'

STDOUT.sync
logger.level = Logger::DEBUG


# Set how we want default output to look for IO
Capistrano::Configuration.default_io_proc = ->(ch, stream, out)  {
  trap("INT") { exit 0; }
  out.gsub(/\r/, "\n")
  lines = out.split("\n")
  tag = "-->   #{Instances.name_from_host(ch[:server].host)} : "
  lines.each do |line|
    say "#{tag}#{line}" unless line.strip.empty?
  end
}

Capistrano::Logger.add_formatter({ :match => /finished `.*/,             :color => :green,   :level => 2, :priority => -10, :timestamp => true })

class Capistrano::Configuration
  def execute_task_with_finished(task)
    execute_task_without_finished(task)
    logger.debug "finished `#{task.fully_qualified_name}'".green
  end
  alias_method_chain :execute_task, :finished

end

