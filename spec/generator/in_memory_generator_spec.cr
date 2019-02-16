require "../../src/crytic/generator/in_memory_generator"
require "../spec_helper"
require "compiler/crystal/syntax/*"

module Crytic::Generator
  specs = ["some_spec.cr"]
  preamble = ""

  describe InMemoryMutationsGenerator do
    describe "#mutations_for" do
      it "returns no mutations for no possibilities" do
        source = fixture_source("non_empty_source_file.cr")

        mutations = InMemoryMutationsGenerator
          .new([] of Mutant::Possibilities, preamble)
          .mutations_for(source, specs)

        mutations.should be_empty
      end

      it "returns no mutations for no possibilities in the source" do
        source = fixture_source("empty_source_file.cr")

        mutations = InMemoryMutationsGenerator
          .new(InMemoryMutationsGenerator::ALL_MUTANTS, preamble)
          .mutations_for(source, specs)

        mutations.should be_empty
      end

      it "returns a number literal mutation for the number literal" do
        source = fixture_source("non_empty_source_file.cr")

        mutations = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities, preamble)
          .mutations_for(source, specs)

        mutations.size.should eq 1
      end

      it "doesn't mix mutations for multiple sources" do
        source = fixture_source("non_empty_source_file.cr")

        generator = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities, preamble)

        generator.mutations_for(source, specs)
        mutations = generator.mutations_for(source, specs)

        mutations.size.should eq 1
      end

      it "passes along the preamble" do
        last_preamble = ""
        factory = ->(config : Mutation::Config) {
          last_preamble = config.preamble
          FakeMutation.new.as(Mutation::Mutation)
        }
        source = fixture_source("non_empty_source_file.cr")

        generator = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities, "preamble")
        generator.mutation_factory = factory

        generator.mutations_for(source, specs)

        last_preamble.should eq "preamble"
      end

      it "passes along the source filename" do
        source = fixture_source("non_empty_source_file.cr")
        last_mutant : Mutant::Mutant? = nil
        factory = ->(config : Mutation::Config) {
          last_mutant = config.mutant
          FakeMutation.new.as(Mutation::Mutation)
        }

        generator = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities, preamble)
        generator.mutation_factory = factory

        generator.mutations_for(source, specs)

        last_mutant.try(&.location).to_s.should contain "#{source.first}"
      end
    end
  end
end

# Gotta have this here becaus __DIR__ evaluates at compile time and therefore means
# that when we run crytic on this codebase itself, it will fail because __DIR__ would
# evaluate to "." which is not the correct path. See https://github.com/hanneskaeufler/crytic/issues/19
DIR = "./spec/generator"

private def fixture_source(filename)
  ["#{DIR}/#{filename}"]
end
