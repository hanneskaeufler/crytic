module Crytic
  # Defines the interface to run arbitrary processes outside
  # the crytic process itself
  abstract class ProcessRunner
    SUCCESS =  0
    TIMEOUT = 28

    # Run a process with the given command and args.
    # Returns the status code of the finished process
    abstract def run(cmd : String, args, output, error)
  end
end
