task(:noop)   { puts "Doin' Nothin'" }
task(:pry)    { require "pry"; binding.pry }
task(:delay)  { sleep 5 }
