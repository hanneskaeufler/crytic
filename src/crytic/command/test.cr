require "../cli_options"
require "../generator/in_memory_generator"
require "../generator/isolated_mutation_factory"
require "../runner/sequential"
require "../subject"

class Crytic::Command::Test
  def initialize(
    @std_out : IO,
    @std_err : IO,
    @exit_fun : (Int32) ->,
    @env : Hash(String, String))
  end

  def execute(args)
    options = parse_options(args)
    generator = build_generator(options)

    Crytic::Runner::Sequential
      .new(options.msi_threshold, options.reporters, generator)
      .run(options.subject, options.spec_files)
  end

  private def parse_options(args)
    Crytic::CliOptions
      .new(@std_out, @std_err, @exit_fun, @env, Crytic::CliOptions::DEFAULT_SPEC_FILES_GLOB)
      .parse(args)
  end

  private def build_generator(options)
    Crytic::Generator::InMemoryMutationsGenerator.new(
      options.mutants,
      options.preamble,
      ->Crytic::Generator.isolated_mutation_factory(Crytic::Mutation::Config))
  end
end
