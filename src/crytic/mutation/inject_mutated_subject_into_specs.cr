require "./require_resolver"
require "compiler/crystal/syntax/*"
require "digest"
require "file_utils"

module Crytic::Mutation
  class Tracker
    private property already_parsed_file_name = Set(String).new
    private property file_list = [] of InjectMutatedSubjectIntoSpecs
    property require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)

    def register_file(file)
      already_parsed_file_name.add(file.path)
      file_list << file
    end

    def track_file(file)
      already_parsed_file_name.add(file)
    end

    def already_tracked?(file)
      already_parsed_file_name.includes?(file)
    end

    def parse_file(file)
      unless already_tracked?(file)
        track_file(file)
        yield
      end
    end
  end

  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    # Because the class is used and instantiated multiple times, but these are
    # class vars, they need to be reset :(
    def self.reset
      @@tracker = Tracker.new
    end

    class_getter tracker = Tracker.new
    class_getter! project_path : String

    getter! astree : Crystal::ASTNode
    getter! enriched_source : String

    getter path : String
    getter source : String

    def self.relative_path_to_project(path)
      @@project_path ||= FileUtils.pwd
      path.gsub(/^#{InjectMutatedSubjectIntoSpecs.project_path}\//, "")
    end

    def initialize(@path, @source, @mutated_subject : MutatedSubject)
      @path = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.expand_path(@path, "."))
      @@tracker.register_file(self)
    end

    # Inject in AST tree if required.
    def process
      unless @astree
        @astree = Crystal::Parser.parse(source)
        astree.accept(self)
      end
    end

    def to_mutated_source
      if @enriched_source.nil?
        # call process to enrich AST before
        # injection of cover head dependencies
        process

        @enriched_source = unfold_required(astree.to_s)
      else
        @enriched_source.not_nil!
      end
    end

    private def unfold_required(output)
      output.gsub(/require\s+"\$(\d+)"/) do |_str, matcher|
        expansion_id = matcher[1].to_i
        file_list = @@tracker.require_expanders[expansion_id]

        String.build do |io|
          file_list.each do |file|
            io << "# require of `#{file.path}` from `#{self.path}`\n"
            io << file.to_mutated_source
          end
        end
      end
    end

    # Management of required file is nasty and should be improved
    # Since I've hard time to replace node on visit,
    # I change the file argument to a number linked to an array of files
    # Then on finalization, we replace each require "xxx" by the proper file.
    def visit(node : Crystal::Require)
      file = node.string
      return false unless file.starts_with?(".")

      new_files_to_load = RequireResolver
        .new
        .find_in_path_relative_to_dir(file, current_directory)

      return if new_files_to_load.nil?

      idx = @@tracker.require_expanders.size
      list_of_required_file = [] of InjectMutatedSubjectIntoSpecs
      @@tracker.require_expanders << list_of_required_file

      new_files_to_load.each do |file_to_load|
        @@tracker.parse_file(InjectMutatedSubjectIntoSpecs.relative_path_to_project(file_to_load)) do
          required_file = InjectMutatedSubjectIntoSpecs.new(
            path: file_to_load,
            source: @mutated_subject.source_or_other_source(file_to_load),
            mutated_subject: @mutated_subject)

          required_file.process # Process on load, since it can change the requirement order

          list_of_required_file << required_file
        end
      end

      node.string = "$#{idx}"

      false
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    private def current_directory
      InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.dirname(@path))
    end
  end
end
