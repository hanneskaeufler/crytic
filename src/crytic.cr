require "./crytic/*"

exit(Crytic::Runner.new.call(ARGV) ? 0 : 1)
