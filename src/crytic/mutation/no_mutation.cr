require "./adapt_local_require_paths_to_current_working_dir"

module Crytic::Mutation
  class NoMutation
    def run
      fixed_specs_source = @specs_file_paths.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(AdaptLocalRequirePathsToCurrentWorkingDir.new(@subject_file_path, spec_file))
        spec_code.to_s
      end.join("\n")

      io = IO::Memory.new

      result = Process.run("crystal", ["eval", fixed_specs_source],
        output: io,
        error: io)
      OriginalResult.new(exit_code: result.exit_code, output: io.to_s)
    end

    def self.with(original : String, specs : Array(String))
      new(original, specs)
    end

    private def initialize(@subject_file_path : String, @specs_file_paths : Array(String))
    end
  end

  record OriginalResult, exit_code : Int32, output : String
end
