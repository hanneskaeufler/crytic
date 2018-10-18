module Crytic
  # Defines the interface to run arbitrary processes outside
  # the crytic process itself
  abstract class ProcessRunner
    # Run a process with the given command and args.
    # Returns the status code of the finished process
    abstract def run(cmd : String, args, output, error) : Int32
  end
end
