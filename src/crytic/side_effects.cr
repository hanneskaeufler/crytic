require "./process_runner"

class Crytic::SideEffects
  getter std_out : IO
  getter std_err : IO
  getter exit_fun : (Int32) ->
  getter env : Hash(String, String)

  delegate :run, to: @process_runner

  def initialize(
    @std_out,
    @std_err,
    @exit_fun,
    @env,
    @process_runner : ProcessRunner,
    @file_remover : (String -> Void),
    @tempfile_writer : ((String, String, String) -> String),
  )
  end

  def execute(cmd, args, output, error)
    @process_runner.run(cmd, args, output, error)
  end

  def execute(cmd, args, output, error, timeout)
    @process_runner.run(cmd, args, output, error, timeout)
  end

  def remove_file(path)
    @file_remover.call(path)
  end

  def write_tempfile(path, ext, content)
    @tempfile_writer.call(path, ext, content)
  end
end
