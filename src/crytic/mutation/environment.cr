require "../process_runner"
require "./config"

module Crytic::Mutation
  record Environment,
    config : Config,
    process_runner : Crytic::ProcessRunner,
    file_remover : (String -> Void),
    tempfile_writer : (String, String, String) -> String do
    delegate :subject, :mutant, :preamble, to: config

    def perform_mutation
      subject.mutated(mutant)
    end

    def subject_path
      subject.path
    end

    def spec_file_paths
      config.specs
    end

    def execute(cmd, args, output, error)
      process_runner.run(cmd, args, output, error)
    end

    def execute(cmd, args, output, error, timeout)
      process_runner.run(cmd, args, output, error, timeout)
    end

    def remove_file(path)
      file_remover.call(path)
    end

    def write_tempfile(path, ext, content)
      tempfile_writer.call(path, ext, content)
    end
  end
end
