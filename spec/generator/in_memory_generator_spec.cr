require "../../src/crytic/generator/in_memory_generator"
require "../spec_helper"

module Crytic::Generator
  specs = ["some_spec.cr"]
  preamble = ""

  describe InMemoryMutationsGenerator do
    describe "#mutations_for" do
      it "returns no mutations for no possibilities" do
        subject = fixture_subject("non_empty_source_file.cr")

        mutations = InMemoryMutationsGenerator
          .new([] of Mutant::Possibilities,
            preamble, fake_mutation_factory, side_effects)
          .mutations_for(subject, specs)

        mutations.should be_empty
      end

      it "returns no mutations for no possibilities in the subject" do
        subject = fixture_subject("empty_source_file.cr")

        mutations = InMemoryMutationsGenerator
          .new(InMemoryMutationsGenerator::ALL_MUTANTS, preamble, fake_mutation_factory, side_effects)
          .mutations_for(subject, specs)

        mutations.should be_empty
      end

      it "returns a number literal mutation for the number literal" do
        subject = fixture_subject("non_empty_source_file.cr")

        mutations = InMemoryMutationsGenerator.new(
          [Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities,
          preamble,
          fake_mutation_factory,
          side_effects)
          .mutations_for(subject, specs)

        mutations.size.should eq 1
      end

      it "passes along the preamble" do
        last_preamble = ""
        factory = ->(env : Mutation::Environment) {
          last_preamble = env.config.preamble
          FakeMutation.new.as(Mutation::Mutation)
        }
        subject = fixture_subject("non_empty_source_file.cr")

        generator = InMemoryMutationsGenerator.new(
          [Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities,
          "preamble",
          factory,
          side_effects)

        generator.mutations_for(subject, specs)

        last_preamble.should eq "preamble"
      end
    end
  end
end

# Gotta have this here becaus __DIR__ evaluates at compile time and therefore means
# that when we run crytic on this codebase itself, it will fail because __DIR__ would
# evaluate to "." which is not the correct path. See https://github.com/hanneskaeufler/crytic/issues/19
DIR = "./spec/generator"

private def fixture_subject(filename)
  [Crytic::Subject.from_filepath("#{DIR}/#{filename}")]
end
