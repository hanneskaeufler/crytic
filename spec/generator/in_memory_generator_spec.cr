require "../../src/crytic/generator/in_memory_generator"
require "../spec_helper"
require "compiler/crystal/syntax/*"

# Gotta have this here becaus __DIR__ evaluates at compile time and therefore means
# that when we run crytic on this codebase itself, it will fail because __DIR__ would
# evaluate to "." which is not the correct path. See https://github.com/hanneskaeufler/crytic/issues/19
DIR = "./spec/generator"

module Crytic
  describe InMemoryMutationsGenerator do
    describe "#mutations_for" do
      it "returns no mutations for no possibilities" do
        source = "#{DIR}/non_empty_source_file.cr"
        specs = ["some_spec.cr"]

        mutations = InMemoryMutationsGenerator
          .new([] of Mutant::Possibilities)
          .mutations_for(source, specs)

        mutations.should be_empty
      end

      it "returns no mutations for no possibilities in the source" do
        source = "#{DIR}/empty_source_file.cr"
        specs = ["some_spec.cr"]

        mutations = InMemoryMutationsGenerator.new.mutations_for(source, specs)

        mutations.should be_empty
      end

      it "returns a single mutation for the number literal" do
        source = "#{DIR}/non_empty_source_file.cr"
        specs = ["some_spec.cr"]

        mutations = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities)
          .mutations_for(source, specs)

        mutations.size.should eq 1
      end

      it "doesn't mix mutations for multiple sources" do
        source = "#{DIR}/non_empty_source_file.cr"
        specs = ["some_spec.cr"]

        generator = InMemoryMutationsGenerator
          .new([Mutant::NumberLiteralSignFlipPossibilities.new] of Mutant::Possibilities)

        generator.mutations_for(source, specs)
        mutations = generator.mutations_for(source, specs)

        mutations.size.should eq 1
      end
    end
  end
end
