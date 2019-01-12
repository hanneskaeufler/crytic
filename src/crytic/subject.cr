require "./diff"
require "./mutant/mutant"
require "compiler/crystal/syntax/*"

module Crytic
  class Subject
    getter original_source : String
    getter! mutated_source : String

    def self.from_filepath(subject_file_path : String)
      new(source: File.read(subject_file_path))
    end

    def initialize(@source : String)
      @ast = Crystal::Parser.parse(@source)
      @original_source = @ast.to_s
    end

    def mutate_source!(mutant : Crystal::Transformer)
      @mutated_source ||= @ast.transform(mutant).to_s
    end

    def mutate_source!(mutant : Crystal::Visitor)
      @ast.accept(mutant)
      @mutated_source ||= @ast.to_s
    end

    def diff
      Crytic::Diff.unified_diff(original_source, mutated_source).to_s
    end
  end
end
