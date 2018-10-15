require "../../src/crytic/mutation/inject_mutated_subject_into_specs"
require "compiler/crystal/syntax/*"
require "spec"

module Crytic
  describe InjectMutatedSubjectIntoSpecs do
    # it "can replace the subject in a direct require" do
    #   code = <<-CODE
    #   require "./fixtures/simple/bar"
    #   CODE
    #   InjectMutatedSubjectIntoSpecs
    #     .new("./fixtures/simple/bar.cr", "puts \"mutated source\"", "./fixtures/simple/bar_spec.cr", code)
    #     .processed
    #     .should eq <<-CODE
    #     puts "mutated source"
    #     CODE
    # end

    it "can follow a one level deep require" do
      # code = <<-CODE
      # require "./spec_helper"
      # CODE
      # pro = InjectMutatedSubjectIntoSpecs
      #   .new("./fixtures/simple/bar.cr", "puts \"mutated source\"", "./fixtures/simple/bar_spec.cr", code)

      # pre = pro.processed

      # pp InjectMutatedSubjectIntoSpecs.files

      f = "./fixtures/simple/bar_spec.cr"
      puts Coverage::SourceFile.new(
        path: f,
        source: File.read(f),
        subject_path: "./fixtures/simple/bar.cr",
        mutated_subject_source: "puts \"mutated\""
        ).to_covered_source
      Coverage::SourceFile.reset

      puts "\n\n ---------- \n\n"

      f = "./fixtures/simple/bar_with_helper_spec.cr"
      puts Coverage::SourceFile.new(
        path: f,
        source: File.read(f),
        subject_path: "./fixtures/simple/bar.cr",
        mutated_subject_source: "puts \"mutated\""
      ).to_covered_source

        # pre.should eq <<-CODE
        # require "http"
        # puts "mutated source"
        # CODE
    end
  end
end
