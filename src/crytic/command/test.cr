require "../cli_options"
require "../generator/in_memory_generator"
require "../generator/isolated_mutation_factory"
require "../runner/parallel"
require "../side_effects"
require "../subject"

class Crytic::Command::Test
  def initialize(@side_effects : SideEffects)
  end

  def execute(args)
    options = parse_options(args)
    generator = build_generator(options)
    factory = ->(specs : Array(String)) {
      Mutation::NoMutation.with(specs)
    }

    Crytic::Runner::Parallel
      .new
      .run(Crytic::Runner::Run.from_options(options, generator, factory), @side_effects)
  end

  private def parse_options(args)
    Crytic::CliOptions
      .new(@side_effects, Crytic::CliOptions::DEFAULT_SPEC_FILES_GLOB)
      .parse(args)
  end

  private def build_generator(options)
    Crytic::Generator::InMemoryMutationsGenerator.new(
      options.mutants,
      options.preamble,
      ->Crytic::Generator.isolated_mutation_factory(Crytic::Mutation::Environment),
      @side_effects)
  end
end
