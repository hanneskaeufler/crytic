require "../mutation/inject_mutated_subject_into_specs"
require "../mutation/tracker"
require "../subject"
require "option_parser"

class Crytic::Command::Noop
  DEFAULT_SPEC_FILES_GLOB = "./spec/**/*_spec.cr"

  def initialize(@std_out : IO)
  end

  def execute(args)
    spec_files = Dir[DEFAULT_SPEC_FILES_GLOB]

    OptionParser.parse(args) do |parser|
      parser.unknown_args do |unknown|
        spec_files = unknown unless unknown.empty?
      end
    end

    tracker = Tracker.new
    @std_out.puts(spec_files.map do |spec_file|
      Mutation::InjectMutatedSubjectIntoSpecs
        .new(spec_file, File.read(spec_file), MutatedSubject.new("", "", ""), tracker)
        .to_mutated_source
    end.join("\n"))

    true
  end
end
