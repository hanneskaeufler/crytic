require "../mutation/inject_mutated_subject_into_specs"
require "../mutation/tracker"
require "../runner/argument_validator"
require "../side_effects"
require "../subject"
require "option_parser"

class Crytic::Command::Noop
  DEFAULT_SPEC_FILES_GLOB = "./spec/**/*_spec.cr"
  include Runner::ArgumentValidator

  def initialize(@side_effects : SideEffects, @spec_files_glob : String)
  end

  def execute(args)
    spec_files = parse_args(args)
    validate_args!(spec_files)

    tracker = Mutation::Tracker.new
    @side_effects.std_out.puts(spec_files.map do |spec_file|
      Mutation::InjectMutatedSubjectIntoSpecs
        .new(spec_file, File.read(spec_file), irrelevant_subject, tracker)
        .to_mutated_source
    end.join("\n"))

    true
  end

  private def parse_args(args)
    spec_files = Dir[@spec_files_glob]

    OptionParser.parse(args) do |parser|
      parser.unknown_args do |unknown|
        spec_files = unknown unless unknown.empty?
      end
    end

    spec_files
  end

  # Because this command runs a noop mutation, we never
  # actually have to replace the subject by its mutation.
  private def irrelevant_subject
    MutatedSubject.new("", "", "")
  end
end
