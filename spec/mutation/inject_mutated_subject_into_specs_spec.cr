require "../../src/crytic/mutation/inject_mutated_subject_into_specs"
require "compiler/crystal/syntax/*"
require "../spec_helper"

module Crytic::Mutation
  describe InjectMutatedSubjectIntoSpecs do
    it "can replace the subject in a direct require" do
      spec_file = "./fixtures/simple/bar_spec.cr"
      InjectMutatedSubjectIntoSpecs
        .new(
          tracker: Tracker.new,
          path: spec_file,
          source: File.read(spec_file),
          mutated_subject: mutated_subject(
            path: "./fixtures/simple/bar.cr",
            source_code: "puts \"mutated source\""))
        .to_mutated_source
        .should eq <<-CODE
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/bar_spec.cr`
        puts("mutated source")
        require "spec"

        describe("bar") do
          it("works") do
            bar.should(eq(2))
          end
        end

        CODE
    end

    it "can follow a one level deep require" do
      spec_file = "./fixtures/simple/bar_with_helper_spec.cr"
      InjectMutatedSubjectIntoSpecs
        .new(
          tracker: Tracker.new,
          path: spec_file,
          source: File.read(spec_file),
          mutated_subject: mutated_subject(
            path: "./fixtures/simple/bar.cr",
            source_code: "puts \"mutated source\""))
        .to_mutated_source
        .should eq <<-CODE
        # require of `fixtures/simple/spec_helper.cr` from `fixtures/simple/bar_with_helper_spec.cr`
        require "http"
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/spec_helper.cr`
        puts("mutated source")

        require "spec"

        describe("bar") do
          it("works") do
            bar.should(eq(2))
          end
        end

        CODE
    end

    it "respects the crystal require order" do
      spec_file = "./fixtures/require_order/blog_spec.cr"
      subject_file = "./fixtures/require_order/blog.cr"
      InjectMutatedSubjectIntoSpecs
        .new(
          tracker: Tracker.new,
          path: spec_file,
          source: File.read(spec_file),
          mutated_subject: mutated_subject(
            path: subject_file,
            source_code: File.read(subject_file)))
        .to_mutated_source
        .should eq <<-CODE
        # require of `fixtures/require_order/blog.cr` from `fixtures/require_order/blog_spec.cr`
        # require of `fixtures/require_order/pages/main_layout.cr` from `fixtures/require_order/blog.cr`
        abstract class MainLayout
        end# require of `fixtures/require_order/pages/blog/archive.cr` from `fixtures/require_order/blog.cr`
        class Archive < MainLayout
          def render
            "welcome page"
          end
        end

        class Blog
          def render
            "\#{Archive.new.render} \#{1}"
          end
        end

        require "spec"

        describe(Blog) do
          it("renders") do
            Blog.new.render.should(eq("welcome page 1"))
          end
        end

        CODE
    end

    it "replaces requires that don't yield any files" do
      spec_file = "./fixtures/require_wildcards/foo_spec.cr"
      subject_file = "./fixtures/require_wildcards/foo.cr"
      InjectMutatedSubjectIntoSpecs
        .new(
          tracker: Tracker.new,
          path: spec_file,
          source: File.read(spec_file),
          mutated_subject: mutated_subject(
            path: subject_file,
            source_code: File.read(subject_file)))
        .to_mutated_source
        .should eq <<-CODE
        # require of `fixtures/require_wildcards/foo.cr` from `fixtures/require_wildcards/foo_spec.cr`
        # require of `fixtures/require_wildcards/app.cr` from `fixtures/require_wildcards/foo.cr`


        puts("hi")

        require "spec"

        describe("foo") do
          it("always passes") do
            true.should(eq(true))
          end
        end

        CODE
    end
  end
end
