require "../mutation/inject_mutated_subject_into_specs"
require "../mutation/tracker"
require "../side_effects"
require "../subject"
require "option_parser"

class Crytic::Command::Noop
  DEFAULT_SPEC_FILES_GLOB = "./spec/**/*_spec.cr"

  def initialize(@side_effects : SideEffects, @spec_files_glob : String)
  end

  def execute(args)
    spec_files = parse_args(args)

    tracker = Mutation::Tracker.new
    @side_effects.std_out.puts(spec_files.join("\n") do |spec_file|
      Mutation::InjectMutatedSubjectIntoSpecs
        .new(spec_file, File.read(spec_file), irrelevant_subject, tracker)
        .to_mutated_source
    end)

    true
  end

  private def parse_args(args)
    spec_files = Dir[@spec_files_glob]

    OptionParser.parse(args) do |parser|
      parser.unknown_args do |unknown|
        spec_files = unknown unless unknown.empty?
      end
    end

    if spec_files.empty?
      error "No spec files given or found."
    end

    spec_files.each do |spec_file|
      unless File.exists?(spec_file)
        error "Spec file #{spec_file} doesn't exist."
      end
    end

    spec_files
  end

  # Because this command runs a noop mutation, we never
  # actually have to replace the subject by its mutation.
  private def irrelevant_subject
    MutatedSubject.new("", "", "")
  end

  private def error(msg) : Nil
    @side_effects.std_err.puts msg
    @side_effects.exit_fun.call(1)
  end
end
